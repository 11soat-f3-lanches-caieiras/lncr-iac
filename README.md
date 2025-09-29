[![Infra Base](https://github.com/11soat-f3-lanches-caieiras/lncr-iac/actions/workflows/infra-base.yml/badge.svg?branch=develop)](https://github.com/11soat-f3-lanches-caieiras/lncr-iac/actions/workflows/infra-base.yml)

# LNCR Infrastructure as Code (IaC)

Este repositório contém módulos Terraform para implantação de uma solução completa de infraestrutura em nuvem incluindo VPC, OpenVPN, cluster EKS e API Gateway na AWS.

## 🏗️ Visão Geral da Arquitetura

A infraestrutura foi projetada com uma abordagem modular, fornecendo:

- **Módulo VPC**: Infraestrutura de rede completa com subnets públicas, privadas e de dados
- **Módulo OpenVPN**: Acesso VPN seguro com gerenciamento automatizado de certificados
- **Módulo EKS**: Cluster Kubernetes com grupos de nós gerenciados
- **Módulo API Gateway**: API Gateway HTTP v2 com CORS e throttling

## 📁 Estrutura do Projeto

```
lncr-iac/
├── main.tf                 # Configuração principal da infraestrutura
├── variables.tf            # Variáveis do nível raiz
├── locals.tf              # Valores locais e variáveis computadas
├── providers.tf           # Configuração do provider AWS
├── prd.tfvars             # Variáveis do ambiente de produção
├── docker-compose.yml     # LocalStack para testes locais
├── run-localstack.sh      # Script para executar com LocalStack
└── modules/
    ├── vpc/              # Recursos de VPC e rede
    ├── openvpn/          # Servidor OpenVPN e segurança
    ├── eks/              # Cluster EKS e grupos de nós
    └── api-gateway/      # API Gateway HTTP v2
```

## 🚀 Início Rápido

### Pré-requisitos

- Terraform >= 1.0
- Docker e Docker Compose (para testes LocalStack)
- AWS CLI configurado (para implantação AWS)

### Testes Locais com LocalStack

1. **Iniciar LocalStack e testar infraestrutura:**
   ```bash
   ./run-localstack.sh
   ```

### Implantação AWS

1. **Inicializar Terraform:**
   ```bash
   terraform init
   ```

2. **Planejar implantação:**
   ```bash
   terraform plan -var-file="prd.tfvars"
   ```

3. **Aplicar infraestrutura:**
   ```bash
   terraform apply -var-file="prd.tfvars"
   ```

## 📋 Referência de Variáveis

### Variáveis Globais

| Variável | Tipo | Descrição | Obrigatório |
|----------|------|-----------|-------------|
| `prefix_name` | string | Prefixo para todos os nomes de recursos | ✅ |
| `environment_name` | string | Nome do ambiente (prd/stg/qa/dev/labs) | ✅ |

### Variáveis VPC

| Variável | Tipo | Descrição | Padrão |
|----------|------|-----------|--------|
| `vpc_cidr` | string | Bloco CIDR para VPC | - |
| `number_of_azs` | number | Número de Zonas de Disponibilidade | - |
| `enable_ipv6` | bool | Habilitar IPv6 para VPC | - |
| `create_public_subnets` | bool | Criar subnets públicas | - |
| `create_app_subnets` | bool | Criar subnets de aplicação | - |
| `create_data_subnets` | bool | Criar subnets de dados | - |
| `create_nat` | bool | Criar NAT Gateway | - |
| `nat_gateway_high_availability` | bool | Habilitar HA para NAT Gateway | - |

### Variáveis OpenVPN

| Variável | Tipo | Descrição |
|----------|------|-----------|
| `openvpn_instance_type` | string | Tipo de instância EC2 para OpenVPN |

### Variáveis EKS

| Variável | Tipo | Descrição |
|----------|------|-----------|
| `cluster_version` | string | Versão do Kubernetes |
| `namespaces` | list(string) | Lista de namespaces para criar |
| `instance_type_node_eks` | string | Tipo de instância para nós EKS |

### Variáveis API Gateway

| Variável | Tipo | Descrição | Padrão |
|----------|------|-----------|--------|
| `api_gateway_cors` | object | Configuração CORS | `{}` |
| `api_gateway_throttle` | object | Configurações de throttling | `{}` |

#### Configuração CORS do API Gateway

```hcl
api_gateway_cors = {
  allow_credentials = false
  allow_headers     = ["content-type", "x-amz-date", "authorization", "x-api-key"]
  allow_methods     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  allow_origins     = ["*"]
  max_age          = 86400
}
```

#### Configuração de Throttling do API Gateway

```hcl
api_gateway_throttle = {
  burst_limit = 5000
  rate_limit  = 10000
}
```

## 🏗️ Detalhes dos Módulos

### Módulo VPC (`modules/vpc/`)

Cria uma infraestrutura VPC completa com:
- Subnets públicas, privadas (app) e de dados em múltiplas AZs
- Internet Gateway e NAT Gateways
- Tabelas de rota e grupos de segurança
- Suporte opcional IPv6
- VPC Flow Logs (configurável)

**Recursos Principais:**
- `aws_vpc`
- `aws_subnet` (public, app, data)
- `aws_internet_gateway`
- `aws_nat_gateway`
- `aws_route_table`

### Módulo OpenVPN (`modules/openvpn/`)

Implanta um servidor OpenVPN seguro com:
- Instância EC2 com OpenVPN Access Server
- Grupo de segurança com portas 8080 (HTTP) e 1194 (UDP)
- Roles e políticas IAM para acesso S3 e SSM
- Geração automatizada de par de chaves
- Bucket S3 para armazenamento de certificados
- AWS Secrets Manager para credenciais

**Recursos Principais:**
- `aws_instance`
- `aws_security_group`
- `aws_iam_role`
- `aws_s3_bucket`
- `aws_secretsmanager_secret`

### Módulo EKS (`modules/eks/`)

Cria um cluster EKS pronto para produção com:
- Cluster EKS com versão configurável do Kubernetes
- Grupos de nós gerenciados
- Configuração RBAC
- Criação de múltiplos namespaces
- Integração com Karpenter para auto-scaling

**Recursos Principais:**
- `aws_eks_cluster`
- `aws_eks_node_group`
- `kubernetes_namespace`

### Módulo API Gateway (`modules/api-gateway/`)

Implanta um API Gateway HTTP v2 com:
- API Gateway com configuração CORS
- Stage padrão com auto-deploy
- Configurações de throttling
- Logging CloudWatch
- ARN de execução para integração Lambda

**Recursos Principais:**
- `aws_apigatewayv2_api`
- `aws_apigatewayv2_stage`
- `aws_cloudwatch_log_group`



## 🔧 Exemplos de Configuração

### Ambiente de Produção (`prd.tfvars`)

```hcl
# Configuração Global
prefix_name      = "lncr"
environment_name = "prd"

# Configuração VPC
vpc_cidr = "10.1.0.0/16"
number_of_azs = 2
enable_ipv6 = false
create_public_subnets = true
create_app_subnets = true
create_data_subnets = true
create_nat = true
nat_gateway_high_availability = false

# Configuração OpenVPN
openvpn_instance_type = "t4g.small"

# Configuração EKS
cluster_version = "1.33"
namespaces = ["staging", "monitoring", "argocd"]
instance_type_node_eks = "t3.medium"

# Configuração API Gateway
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

## 🔒 Recursos de Segurança

- **Isolamento de Rede**: Subnets separadas para diferentes camadas
- **Grupos de Segurança**: Regras restritivas de ingress/egress
- **Roles IAM**: Acesso de menor privilégio
- **Criptografia**: Buckets S3 e volumes EBS criptografados
- **Acesso VPN**: Acesso remoto seguro via OpenVPN
- **Gerenciamento de Segredos**: AWS Secrets Manager para dados sensíveis

## 📊 Outputs

Cada módulo fornece outputs relevantes para integração:

### Outputs VPC
- ID e CIDR da VPC
- IDs das Subnets (public, app, data)
- IDs das tabelas de rota
- IDs dos NAT Gateways

### Outputs OpenVPN
- ARN e IP da instância
- ID do Security Group
- Credenciais (sensível)

### Outputs EKS
- Nome e endpoint do cluster
- ARN do cluster
- ARNs dos grupos de nós

### Outputs API Gateway
- ID e endpoint da API
- ARN de execução
- ARN do stage

## 🧪 Testes

### Testes LocalStack

O projeto inclui configuração LocalStack para testes locais:

```bash
# Iniciar LocalStack com serviços necessários
docker-compose up -d

# Testar infraestrutura
terraform plan -var-file="prd.tfvars"
```

### Serviços LocalStack Suportados
- EC2, VPC, IAM, STS
- S3, Secrets Manager
- API Gateway v2
- CloudWatch Logs

## 🏷️ Convenção de Nomenclatura de Recursos

Todos os recursos seguem o padrão de nomenclatura:
```
{prefix_name}-{environment_name}-{resource_type}
```

Exemplo: `lncr-prd-vpc`, `lncr-prd-openvpn-sg`

## 📝 Melhores Práticas

1. **Design Modular**: Cada componente é um módulo separado
2. **Separação de Ambientes**: Use diferentes arquivos tfvars
3. **Gerenciamento de Estado**: Use estado remoto para produção
4. **Segurança**: Siga as melhores práticas de segurança AWS
5. **Monitoramento**: Logging CloudWatch habilitado
6. **Otimização de Custos**: Tipos de instância e scaling configuráveis

## 🤝 Contribuindo

1. Siga a estrutura de módulos existente
2. Atualize a documentação para novas variáveis
3. Teste com LocalStack antes da implantação AWS
4. Use convenções de nomenclatura consistentes
5. Adicione tags apropriadas a todos os recursos

## 📄 Licença

Este projeto está licenciado sob a Licença MIT.
