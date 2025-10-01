module "subnet_calculator" {
  source = "./modules/calculate-subnets"

  cidr_block          = var.vpc_cidr
  number_of_azs       = var.number_of_azs
  create_app_subnets  = var.create_app_subnets
  create_data_subnets = var.create_data_subnets
  eks_cluster_name    = var.eks_cluster_name
}

################################################################################
# VPC
################################################################################
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge({
    Name = "${var.prefix_name}-${var.environment}-vpc"
  })
}

module "flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  source = "./modules/flow-logs"

  prefix_name = var.prefix_name
  environment = var.environment
  vpc_id      = aws_vpc.vpc.id
}

################################################################################
# DHCP Options
################################################################################
resource "aws_vpc_dhcp_options" "dhcp_options" {
  domain_name         = "us-east-1.compute.internal"
  domain_name_servers = ["8.8.8.8", "8.8.4.4"]
  ntp_servers         = ["127.0.0.1"]
  tags = merge({
    Name = "${var.prefix_name}-${var.environment}-dhcp"
  })
}

resource "aws_vpc_dhcp_options_association" "dhcp_association" {
  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_options.id
}

# ################################################################################
# # Internet and NAT Gateways
# ################################################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${var.prefix_name}-${var.environment}-igw"
  })
}

resource "aws_eip" "nat_eip" {
  count = local.nat_gateway_quantity

  tags = merge({
    Name = "eip-nat-${count.index}"
  })
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gw" {
  count = local.nat_gateway_quantity

  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = element([for subnet in values(aws_subnet.public_subnet) : subnet.id], count.index)
  tags = merge({
    Name = "${var.prefix_name}-${var.environment}-nat-gateway-${count.index}"
  })
}

# ################################################################################
# # Subnets
# ################################################################################

resource "aws_subnet" "public_subnet" {
  for_each = {
    for az in module.subnet_calculator.utilized_azs : az => {
      cidr = module.subnet_calculator.calculated_subnets_map["public-${az}"]
    }
  }

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.key

  tags = merge({
    Name                     = "${var.prefix_name}-${var.environment}-public-${each.key}"
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "app_subnet" {
  for_each = var.create_app_subnets ? {
    for az in module.subnet_calculator.utilized_azs : az => {
      cidr = module.subnet_calculator.calculated_subnets_map["private-${az}"]
    }
  } : {}

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.key

  tags = merge({
    Name                     = "${var.prefix_name}-${var.environment}-private-${each.key}"
    "karpenter.sh/discovery" = "${var.eks_cluster_name}"
  })

}

resource "aws_subnet" "data_subnet" {
  for_each = var.create_data_subnets ? {
    for az in module.subnet_calculator.utilized_azs : az => {
      cidr = module.subnet_calculator.calculated_subnets_map["data-${az}"]
    }
  } : {}

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.key

  tags = merge({
    Name = "${var.prefix_name}-${var.environment}-data-${each.key}"
  })
}

# ################################################################################
# # Route Tables
# ################################################################################
resource "aws_route_table" "app_route_table" {
  for_each = var.create_app_subnets ? aws_subnet.app_subnet : {}

  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.prefix_name}-${var.environment}-private-rt-${each.key}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.prefix_name}-${var.environment}-public-route-table"
  }
}

resource "aws_route_table" "data_route_table" {
  for_each = var.create_data_subnets ? aws_subnet.data_subnet : {}

  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.prefix_name}-${var.environment}-data-rt-${each.key}"
  }
}

################################################################################
# Routes
################################################################################
resource "aws_route" "private_route" {
  for_each = aws_route_table.app_route_table

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = local.nat_gateway_quantity == 1 ? aws_nat_gateway.nat_gw[0].id : aws_nat_gateway.nat_gw[index(module.subnet_calculator.utilized_azs, each.key)].id

  depends_on = [aws_route_table.app_route_table]
}

################################################################################
# Route Table Associations
################################################################################
resource "aws_route_table_association" "public_route_table_association" {
  for_each = aws_subnet.public_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_table_association" {
  for_each = var.create_app_subnets ? aws_subnet.app_subnet : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.app_route_table[each.key].id
}

resource "aws_route_table_association" "data_route_table_association" {
  for_each = var.create_data_subnets ? aws_subnet.data_subnet : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.data_route_table[each.key].id
}

################################################################################
# Data Subnet Group
################################################################################
resource "aws_db_subnet_group" "data_subnet_group" {
  count = var.create_data_subnets ? 1 : 0

  name       = "${var.prefix_name}-${var.environment}-data-subnet-group"
  subnet_ids = [for subnet in aws_subnet.data_subnet : subnet.id]

  tags = {
    Name = "${var.prefix_name}-${var.environment}-data-subnet-group"
  }
}

################################################################################
# VPC Endpoint
################################################################################
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [for rt in aws_route_table.app_route_table : rt.id]

  tags = {
    Name = "vpc-endpoint-s3"
  }
}