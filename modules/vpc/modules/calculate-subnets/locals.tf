locals {
  # Safely extract the netmask from CIDR block
  cidr_parts   = split("/", var.cidr_block)
  base_netmask = length(local.cidr_parts) > 1 ? tonumber(local.cidr_parts[1]) : 16

  # Define netmask fixo apenas para blocos /16
  fixed_netmask = var.eks_cluster_name == "" ? 24 : 20

  # Define netmask dinâmico para blocos diferentes de /16
  dynamic_netmask = local.base_netmask + (var.eks_cluster_name == "" ? 8 : 4)

  # Netmask final
  calculated_subnet_netmask = local.base_netmask == 16 ? local.fixed_netmask : min(28, local.dynamic_netmask)

  selected_azs = slice(data.aws_availability_zones.available.names, 0, var.number_of_azs)

  public_subnets = [
    for az_suffix in local.selected_azs : {
      name    = "public-${az_suffix}"
      netmask = local.calculated_subnet_netmask
    }
  ]

  app_subnets = var.create_app_subnets ? [
    for az_suffix in local.selected_azs : {
      name    = "private-${az_suffix}"
      netmask = local.calculated_subnet_netmask
    }
  ] : []

  data_subnets = var.create_data_subnets ? [
    for az_suffix in local.selected_azs : {
      name    = "data-${az_suffix}"
      netmask = local.calculated_subnet_netmask
    }
  ] : []

  networks_definition = concat(
    local.public_subnets,
    local.app_subnets,
    local.data_subnets
  )

  networks_with_new_bits = [
    for network in local.networks_definition : {
      name     = network.name
      netmask  = network.netmask
      new_bits = network.netmask - local.base_netmask
    }
  ]

  calculated_cidr_list = cidrsubnets(var.cidr_block, local.networks_with_new_bits[*].new_bits...)

  calculated_subnets = {
    for i, network in local.networks_with_new_bits : network.name => local.calculated_cidr_list[i]
  }
}