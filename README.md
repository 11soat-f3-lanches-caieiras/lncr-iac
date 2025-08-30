# LNCR Infrastructure as Code (IaC)

This repository contains Terraform modules for deploying a complete cloud infrastructure solution including VPC, OpenVPN, EKS cluster, and API Gateway on AWS.

## 🏗️ Architecture Overview

The infrastructure is designed with a modular approach, providing:

- **VPC Module**: Complete network infrastructure with public, private, and data subnets
- **OpenVPN Module**: Secure VPN access with automated certificate management
- **EKS Module**: Kubernetes cluster with managed node groups
- **API Gateway Module**: HTTP v2 API Gateway with CORS and throttling
- **Karpenter Module**: Auto-scaling for Kubernetes workloads

## 📁 Project Structure

```
lncr-iac/
├── main.tf                 # Main infrastructure configuration
├── variables.tf            # Root-level variables
├── locals.tf              # Local values and computed variables
├── providers.tf           # AWS provider configuration
├── prd.tfvars             # Production environment variables
├── docker-compose.yml     # LocalStack for local testing
├── run-localstack.sh      # Script to run with LocalStack
├── test-vpc.sh           # Script to test VPC module only
└── modules/
    ├── vpc/              # VPC and networking resources
    ├── openvpn/          # OpenVPN server and security
    ├── eks/              # EKS cluster and node groups
    ├── karpenter/        # Karpenter auto-scaling
    └── api-gateway/      # API Gateway HTTP v2
```

## 🚀 Quick Start

### Prerequisites

- Terraform >= 1.0
- Docker and Docker Compose (for LocalStack testing)
- AWS CLI configured (for AWS deployment)

### Local Testing with LocalStack

1. **Start LocalStack and test infrastructure:**
   ```bash
   ./run-localstack.sh
   ```

2. **Test VPC module only:**
   ```bash
   ./test-vpc.sh
   ```

### AWS Deployment

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Plan deployment:**
   ```bash
   terraform plan -var-file="prd.tfvars"
   ```

3. **Apply infrastructure:**
   ```bash
   terraform apply -var-file="prd.tfvars"
   ```

## 📋 Variables Reference

### Global Variables

| Variable | Type | Description | Required |
|----------|------|-------------|----------|
| `prefix_name` | string | Prefix for all resource names | ✅ |
| `environment_name` | string | Environment name (prd/stg/qa/dev/labs) | ✅ |

### VPC Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `vpc_cidr` | string | CIDR block for VPC | - |
| `number_of_azs` | number | Number of Availability Zones | - |
| `enable_ipv6` | bool | Enable IPv6 for VPC | - |
| `create_public_subnets` | bool | Create public subnets | - |
| `create_app_subnets` | bool | Create application subnets | - |
| `create_data_subnets` | bool | Create data subnets | - |
| `create_nat` | bool | Create NAT Gateway | - |
| `nat_gateway_high_availability` | bool | Enable HA for NAT Gateway | - |

### OpenVPN Variables

| Variable | Type | Description |
|----------|------|-------------|
| `openvpn_instance_type` | string | EC2 instance type for OpenVPN |

### EKS Variables

| Variable | Type | Description |
|----------|------|-------------|
| `cluster_version` | string | Kubernetes version |
| `namespaces` | list(string) | List of namespaces to create |
| `instance_type_node_eks` | string | Instance type for EKS nodes |

### API Gateway Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `api_gateway_cors` | object | CORS configuration | `{}` |
| `api_gateway_throttle` | object | Throttling settings | `{}` |

#### API Gateway CORS Configuration

```hcl
api_gateway_cors = {
  allow_credentials = false
  allow_headers     = ["content-type", "x-amz-date", "authorization", "x-api-key"]
  allow_methods     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  allow_origins     = ["*"]
  max_age          = 86400
}
```

#### API Gateway Throttling Configuration

```hcl
api_gateway_throttle = {
  burst_limit = 5000
  rate_limit  = 10000
}
```

## 🏗️ Module Details

### VPC Module (`modules/vpc/`)

Creates a complete VPC infrastructure with:
- Public, private (app), and data subnets across multiple AZs
- Internet Gateway and NAT Gateways
- Route tables and security groups
- Optional IPv6 support
- VPC Flow Logs (configurable)

**Key Resources:**
- `aws_vpc`
- `aws_subnet` (public, app, data)
- `aws_internet_gateway`
- `aws_nat_gateway`
- `aws_route_table`

### OpenVPN Module (`modules/openvpn/`)

Deploys a secure OpenVPN server with:
- EC2 instance with OpenVPN Access Server
- Security group with ports 8080 (HTTP) and 1194 (UDP)
- IAM roles and policies for S3 and SSM access
- Automated key pair generation
- S3 bucket for certificate storage
- AWS Secrets Manager for credentials

**Key Resources:**
- `aws_instance`
- `aws_security_group`
- `aws_iam_role`
- `aws_s3_bucket`
- `aws_secretsmanager_secret`

### EKS Module (`modules/eks/`)

Creates a production-ready EKS cluster with:
- EKS cluster with configurable Kubernetes version
- Managed node groups
- RBAC configuration
- Multiple namespace creation
- Integration with Karpenter for auto-scaling

**Key Resources:**
- `aws_eks_cluster`
- `aws_eks_node_group`
- `kubernetes_namespace`

### API Gateway Module (`modules/api-gateway/`)

Deploys an HTTP v2 API Gateway with:
- API Gateway with CORS configuration
- Default stage with auto-deploy
- Throttling settings
- CloudWatch logging
- Execution ARN for Lambda integration

**Key Resources:**
- `aws_apigatewayv2_api`
- `aws_apigatewayv2_stage`
- `aws_cloudwatch_log_group`

### Karpenter Module (`modules/karpenter/`)

Provides auto-scaling capabilities with:
- Karpenter controller installation
- Node pools and node classes
- Instance family and CPU-based filtering
- Spot instance support

## 🔧 Configuration Examples

### Production Environment (`prd.tfvars`)

```hcl
# Global Configuration
prefix_name      = "lncr"
environment_name = "prd"

# VPC Configuration
vpc_cidr = "10.1.0.0/16"
number_of_azs = 2
enable_ipv6 = false
create_public_subnets = true
create_app_subnets = true
create_data_subnets = true
create_nat = true
nat_gateway_high_availability = false

# OpenVPN Configuration
openvpn_instance_type = "t4g.small"

# EKS Configuration
cluster_version = "1.33"
namespaces = ["staging", "monitoring", "argocd"]
instance_type_node_eks = "t3.medium"

# API Gateway Configuration
api_gateway_cors = {
  allow_credentials = false
  allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key"]
  allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  allow_origins = ["*"]
  max_age = 86400
}

api_gateway_throttle = {
  burst_limit = 5000
  rate_limit = 10000
}
```

## 🔒 Security Features

- **Network Isolation**: Separate subnets for different tiers
- **Security Groups**: Restrictive ingress/egress rules
- **IAM Roles**: Least privilege access
- **Encryption**: S3 buckets and EBS volumes encrypted
- **VPN Access**: Secure remote access via OpenVPN
- **Secrets Management**: AWS Secrets Manager for sensitive data

## 📊 Outputs

Each module provides relevant outputs for integration:

### VPC Outputs
- VPC ID and CIDR
- Subnet IDs (public, app, data)
- Route table IDs
- NAT Gateway IDs

### OpenVPN Outputs
- Instance ARN and IP
- Security Group ID
- Credentials (sensitive)

### EKS Outputs
- Cluster name and endpoint
- Cluster ARN
- Node group ARNs

### API Gateway Outputs
- API ID and endpoint
- Execution ARN
- Stage ARN

## 🧪 Testing

### LocalStack Testing

The project includes LocalStack configuration for local testing:

```bash
# Start LocalStack with required services
docker-compose up -d

# Test infrastructure
terraform plan -var-file="prd.tfvars"
```

### Supported LocalStack Services
- EC2, VPC, IAM, STS
- S3, Secrets Manager
- API Gateway v2
- CloudWatch Logs

## 🏷️ Resource Naming Convention

All resources follow the naming pattern:
```
{prefix_name}-{environment_name}-{resource_type}
```

Example: `lncr-prd-vpc`, `lncr-prd-openvpn-sg`

## 📝 Best Practices

1. **Modular Design**: Each component is a separate module
2. **Environment Separation**: Use different tfvars files
3. **State Management**: Use remote state for production
4. **Security**: Follow AWS security best practices
5. **Monitoring**: CloudWatch logging enabled
6. **Cost Optimization**: Configurable instance types and scaling

## 🤝 Contributing

1. Follow the existing module structure
2. Update documentation for new variables
3. Test with LocalStack before AWS deployment
4. Use consistent naming conventions
5. Add appropriate tags to all resources

## 📄 License

This project is licensed under the MIT License.