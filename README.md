[![Infra Base](https://github.com/11soat-f3-lanches-caieiras/lncr-iac/actions/workflows/infra-base.yml/badge.svg?branch=develop)](https://github.com/11soat-f3-lanches-caieiras/lncr-iac/actions/workflows/infra-base.yml)

# 🏗️ LNCR Infrastructure as Code (IaC)

Este repositório contém a infraestrutura completa como código para o projeto LNCR (Lanches Caieiras), implementando uma arquitetura moderna e escalável na AWS usando Terraform. A solução inclui VPC, EKS, OpenVPN, API Gateway, ECR, CodeBuild e outros serviços essenciais.

## 📋 Índice

- [Visão Geral da Arquitetura](#-visão-geral-da-arquitetura)
- [Recursos Provisionados](#-recursos-provisionados)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Pré-requisitos](#-pré-requisitos)
- [Início Rápido](#-início-rápido)
- [Workflows CI/CD](#-workflows-cicd)
- [Módulos Detalhados](#-módulos-detalhados)
- [Variáveis de Configuração](#-variáveis-de-configuração)
- [Outputs](#-outputs)
- [Segurança](#-segurança)
- [Monitoramento](#-monitoramento)
- [Troubleshooting](#-troubleshooting)
- [Contribuição](#-contribuição)

## 🏛️ Visão Geral da Arquitetura

A infraestrutura foi projetada seguindo as melhores práticas de segurança e escalabilidade:

```
┌─────────────────────────────────────────────────────────────────┐
│                           AWS Cloud                             │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌──────────────────────────────────────┐ │
│  │   API Gateway   │────│            VPC Network              │ │
│  │   (HTTP v2)     │    │  ┌─────────────┐  ┌─────────────────┐│ │
│  └─────────────────┘    │  │   Public    │  │    Private      ││ │
│                         │  │   Subnets   │  │    Subnets      ││ │
│  ┌─────────────────┐    │  │             │  │                 ││ │
│  │     Lambda      │    │  │  OpenVPN    │  │   EKS Cluster   ││ │
│  │  (Authorizer)   │    │  │   Server    │  │   + Nodes       ││ │
│  └─────────────────┘    │  └─────────────┘  └─────────────────┘│ │
│                         │                                      │ │
│  ┌─────────────────┐    │  ┌─────────────┐  ┌─────────────────┐│ │
│  │      ECR        │    │  │    Data     │  │   FSx OpenZFS   ││ │
│  │ (Repositories)  │    │  │   Subnets   │  │   (Storage)     ││ │
│  └─────────────────┘    │  └─────────────┘  └─────────────────┘│ │
│                         └──────────────────────────────────────┘ │
│  ┌─────────────────┐                                             │
│  │   CodeBuild     │    ┌──────────────────────────────────────┐ │
│  │   Projects      │    │        Secrets Manager              │ │
│  └─────────────────┘    └──────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 🚀 Recursos Provisionados

### Infraestrutura de Rede
- **VPC** com subnets públicas, privadas e de dados
- **Internet Gateway** e **NAT Gateways**
- **Route Tables** e associações
- **Security Groups** com regras específicas
- **VPC Endpoints** para S3

### Compute e Container
- **EKS Cluster** (Kubernetes 1.33) com managed node groups
- **EC2 Instance** para OpenVPN Server
- **Lambda Functions** para custom authorizer
- **ALB Controller** para load balancing

### Storage e Dados
- **ECR Repositories** para imagens Docker
- **FSx OpenZFS** para storage compartilhado
- **S3 Buckets** para artefatos e certificados

### CI/CD e DevOps
- **CodeBuild Projects** para automação
- **GitHub Actions** workflows
- **Secrets Manager** para credenciais

### API e Networking
- **API Gateway HTTP v2** com CORS e throttling
- **VPC Links** para integração privada
- **Custom Authorizer** com Lambda

### Monitoramento
- **CloudWatch Log Groups** para logs
- **KMS Keys** para criptografia
- **IAM Roles e Policies** para segurança

## 📁 Estrutura do Projeto

```
lncr-iac/
├── .github/
│   └── workflows/              # GitHub Actions workflows
│       ├── bootstrap.yml       # Deploy inicial (VPC + CodeBuild)
│       ├── infra-base.yml      # Deploy base infrastructure
│       └── infra-complete.yml  # Deploy completo com API Gateway
├── modules/                    # Módulos Terraform reutilizáveis
│   ├── vpc/                   # Infraestrutura de rede
│   ├── eks/                   # Cluster Kubernetes
│   ├── openvpn/               # Servidor VPN
│   ├── api-gateway/           # API Gateway HTTP v2
│   ├── ecr/                   # Container Registry
│   ├── codebuild/             # CI/CD Projects
│   ├── lambda/                # Functions serverless
│   ├── alb-controller/        # Load Balancer Controller
│   ├── secrets-manager/       # Gerenciamento de segredos
│   └── fsx-openzfs/          # Storage compartilhado
├── main.tf                    # Configuração principal
├── variables.tf               # Definições de variáveis
├── locals.tf                  # Valores locais
├── providers.tf               # Configuração de providers
├── prd.tfvars                # Variáveis do ambiente produção
└── README.md                  # Esta documentação
```

## 🔧 Pré-requisitos

### Software Necessário
- **Terraform** >= 1.5.7
- **AWS CLI** configurado
- **kubectl** para gerenciar EKS
- **Docker** (opcional, para testes locais)
- **Git** para versionamento

### Credenciais AWS
```bash
# Configure suas credenciais AWS
aws configure

# Ou use variáveis de ambiente
export AWS_ACCESS_KEY_ID="sua-access-key"
export AWS_SECRET_ACCESS_KEY="sua-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### Permissões IAM Necessárias
O usuário/role deve ter permissões para:
- EC2, VPC, EKS, Lambda, API Gateway
- IAM, S3, ECR, CodeBuild
- Secrets Manager, KMS, CloudWatch
- FSx, ELB, Route53

## 🚀 Início Rápido

### 1. Clone o Repositório
```bash
git clone https://github.com/11soat-f3-lanches-caieiras/lncr-iac.git
cd lncr-iac
```

### 2. Inicialize o Terraform
```bash
terraform init
```

### 3. Valide a Configuração
```bash
terraform validate
terraform fmt
```

### 4. Planeje a Implantação
```bash
terraform plan -var-file="prd.tfvars"
```

### 5. Aplique a Infraestrutura

#### Opção A: Deploy Completo
```bash
terraform apply -var-file="prd.tfvars"
```

#### Opção B: Deploy por Etapas (Recomendado)

**Etapa 1: Infraestrutura Base**
```bash
terraform apply \
  -target=module.vpc \
  -target=module.codebuild \
  -var-file="prd.tfvars" \
  -auto-approve
```

**Etapa 2: Serviços Core**
```bash
terraform apply \
  -target=module.eks \
  -target=module.ecr \
  -target=module.secrets_manager \
  -target=module.openvpn \
  -target=module.lambda \
  -var-file="prd.tfvars" \
  -auto-approve
```

**Etapa 3: API Gateway e Integrações**
```bash
# Obter ARNs necessários
NLB_LISTENER_ARN=$(aws elbv2 describe-listeners --load-balancer-arn $(aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerArn" --output text | grep lncr | head -1) --query "Listeners[0].ListenerArn" --output text)

FUNCTION_ARN=$(aws lambda get-function --function-name lncr-prd-custom-authorizer --query 'Configuration.FunctionArn' --output text)

terraform apply \
  -target=module.api_gateway \
  -var="eks_nlb_listener_arn=$NLB_LISTENER_ARN" \
  -var="lambda_function_arn=$FUNCTION_ARN" \
  -var-file="prd.tfvars" \
  -auto-approve
```

### 6. Configure kubectl para EKS
```bash
aws eks update-kubeconfig --region us-east-1 --name lncr-prd-eks
kubectl get nodes
```

## 🔄 Workflows CI/CD

### Bootstrap Workflow
**Arquivo**: `.github/workflows/bootstrap.yml`
- **Trigger**: Manual (workflow_dispatch)
- **Função**: Deploy inicial da VPC e CodeBuild
- **Uso**: Primeira execução para criar infraestrutura base

### Infra Base Workflow
**Arquivo**: `.github/workflows/infra-base.yml`
- **Trigger**: Push para branch `develop` ou manual
- **Recursos**: VPC, EKS, ECR, Secrets Manager, FSx, OpenVPN, Lambda
- **Runner**: CodeBuild personalizado
- **Integração**: Dispara deploys em outros repositórios

### Infra Complete Workflow
**Arquivo**: `.github/workflows/infra-complete.yml`
- **Trigger**: Push para `develop`, repository_dispatch ou manual
- **Recursos**: API Gateway com integrações NLB e Lambda
- **Dependências**: Requer infraestrutura base já implantada

### Configuração de Secrets
Configure os seguintes secrets no GitHub:
```
AWS_ACCESS_KEY_ID       # Chave de acesso AWS
AWS_SECRET_ACCESS_KEY   # Chave secreta AWS
REPO_TOKEN             # Token para disparar workflows em outros repos
```

## 📦 Módulos Detalhados

### Módulo VPC (`modules/vpc/`)
**Recursos Criados:**
- VPC com CIDR configurável
- Subnets públicas, privadas (app) e de dados
- Internet Gateway e NAT Gateways
- Route Tables e associações
- Security Groups
- VPC Endpoints (S3)
- DB Subnet Groups

**Características:**
- Suporte a múltiplas AZs
- IPv6 opcional
- NAT Gateway com HA opcional
- Tags para EKS e Karpenter

### Módulo EKS (`modules/eks/`)
**Recursos Criados:**
- EKS Cluster com versão configurável
- Managed Node Groups
- Security Groups específicos
- IAM Roles e Policies
- KMS Key para criptografia
- Storage Classes (GP3)
- Namespaces customizados
- AWS Auth ConfigMap

**Add-ons Inclusos:**
- kube-proxy
- eks-pod-identity-agent
- vpc-cni
- aws-ebs-csi-driver
- coredns

### Módulo OpenVPN (`modules/openvpn/`)
**Recursos Criados:**
- EC2 Instance com OpenVPN Access Server
- Security Group (portas 8080/TCP, 1194/UDP)
- IAM Role com políticas S3 e SSM
- Key Pair para acesso SSH
- S3 Bucket para certificados
- Secrets Manager para credenciais
- User Data script para configuração

### Módulo API Gateway (`modules/api-gateway/`)
**Recursos Criados:**
- API Gateway HTTP v2
- Stage padrão com auto-deploy
- CORS configuration
- Throttling settings
- VPC Link para EKS
- Custom Authorizer com Lambda
- CloudWatch Log Groups
- Rotas protegidas e abertas

### Módulo ECR (`modules/ecr/`)
**Recursos Criados:**
- Repositórios ECR
- Lifecycle policies
- Image scanning
- Tag mutability settings

### Módulo CodeBuild (`modules/codebuild/`)
**Recursos Criados:**
- Projetos CodeBuild
- IAM Roles e Policies
- Security Groups
- VPC Configuration
- GitHub Webhooks
- GitHub Actions Runners

### Módulo Lambda (`modules/lambda/`)
**Recursos Criados:**
- Lambda Functions
- IAM Roles
- Environment Variables
- Deployment Packages

### Módulo ALB Controller (`modules/alb-controller/`)
**Recursos Criados:**
- Helm Release para AWS Load Balancer Controller
- Service Account com IRSA
- IAM Roles e Policies
- Kubernetes Namespace

### Módulo Secrets Manager (`modules/secrets-manager/`)
**Recursos Criados:**
- Secrets para aplicações
- Recovery window configurável
- Tags padronizadas

### Módulo FSx OpenZFS (`modules/fsx-openzfs/`)
**Recursos Criados:**
- FSx OpenZFS File System
- Security Groups
- Backup configuration
- Performance settings

## ⚙️ Variáveis de Configuração

### Variáveis Globais
| Variável | Tipo | Descrição | Exemplo |
|----------|------|-----------|---------|
| `prefix_name` | string | Prefixo para recursos | `"lncr"` |
| `environment_name` | string | Nome do ambiente | `"prd"` |

### Variáveis VPC
| Variável | Tipo | Descrição | Padrão |
|----------|------|-----------|--------|
| `vpc_cidr` | string | CIDR da VPC | `"10.1.0.0/16"` |
| `number_of_azs` | number | Número de AZs | `2` |
| `enable_ipv6` | bool | Habilitar IPv6 | `false` |
| `create_public_subnets` | bool | Criar subnets públicas | `true` |
| `create_app_subnets` | bool | Criar subnets privadas | `true` |
| `create_data_subnets` | bool | Criar subnets de dados | `true` |
| `create_nat` | bool | Criar NAT Gateway | `true` |
| `nat_gateway_high_availability` | bool | NAT HA | `false` |

### Variáveis EKS
| Variável | Tipo | Descrição | Padrão |
|----------|------|-----------|--------|
| `cluster_version` | string | Versão Kubernetes | `"1.33"` |
| `namespaces` | list(string) | Namespaces | `["staging", "monitoring", "argocd"]` |
| `instance_type_node_eks` | string | Tipo instância nós | `"t3.medium"` |

### Variáveis API Gateway
| Variável | Tipo | Descrição |
|----------|------|-----------|
| `api_gateway_cors` | object | Configuração CORS |
| `api_gateway_throttle` | object | Configuração throttling |

### Exemplo de Configuração CORS
```hcl
api_gateway_cors = {
  allow_credentials = false
  allow_headers     = ["content-type", "x-amz-date", "authorization", "x-api-key"]
  allow_methods     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  allow_origins     = ["*"]
  max_age           = 86400
}
```

### Exemplo de Configuração Throttling
```hcl
api_gateway_throttle = {
  burst_limit = 5000
  rate_limit  = 10000
}
```

### Variáveis CodeBuild
```hcl
codebuild_projects = {
  "iac" = {
    codebuild_name  = "github-lncr-iac"
    github_repo_url = "https://github.com/11soat-f3-lanches-caieiras/lncr-iac"
  },
  "app" = {
    codebuild_name  = "github-lncr-app"
    github_repo_url = "https://github.com/11soat-f3-lanches-caieiras/lncr-app"
  }
}
```

## 📤 Outputs

### Outputs Principais
```hcl
# VPC
vpc_id                    # ID da VPC
public_subnet_ids         # IDs das subnets públicas
app_subnet_ids           # IDs das subnets privadas
data_subnet_ids          # IDs das subnets de dados

# EKS
cluster_name             # Nome do cluster EKS
cluster_endpoint         # Endpoint do cluster
cluster_security_group_id # ID do security group
oidc_provider_arn        # ARN do OIDC provider

# API Gateway
api_gateway_id           # ID do API Gateway
api_gateway_endpoint     # Endpoint da API
api_execution_arn        # ARN de execução

# ECR
ecr_repository_urls      # URLs dos repositórios ECR

# CodeBuild
codebuild_project_names  # Nomes dos projetos CodeBuild
```

## 🔒 Segurança

### Práticas Implementadas

#### Rede
- **Isolamento**: Subnets separadas por função (pública, privada, dados)
- **NAT Gateway**: Acesso internet controlado para subnets privadas
- **Security Groups**: Regras restritivas de ingress/egress
- **VPC Endpoints**: Comunicação privada com serviços AWS

#### Identidade e Acesso
- **IAM Roles**: Princípio do menor privilégio
- **IRSA**: Service Accounts com roles específicas
- **Custom Authorizer**: Autenticação/autorização customizada
- **Secrets Manager**: Armazenamento seguro de credenciais

#### Criptografia
- **KMS**: Chaves gerenciadas para EKS
- **EBS Encryption**: Volumes criptografados
- **S3 Encryption**: Buckets com criptografia
- **TLS**: Comunicação criptografada

#### Monitoramento
- **CloudWatch Logs**: Logs centralizados
- **VPC Flow Logs**: Monitoramento de tráfego de rede
- **API Gateway Logs**: Logs de requisições
- **EKS Audit Logs**: Logs de auditoria Kubernetes

### Security Groups

#### EKS Cluster Security Group
```
Ingress:
- 443/TCP from 0.0.0.0/0 (Kubernetes API)
- All traffic from VPC CIDR

Egress:
- All traffic to 0.0.0.0/0
```

#### OpenVPN Security Group
```
Ingress:
- 8080/TCP from 0.0.0.0/0 (Web Interface)
- 1194/UDP from 0.0.0.0/0 (VPN Traffic)

Egress:
- All traffic to 0.0.0.0/0
```

#### CodeBuild Security Group
```
Egress:
- All traffic to 0.0.0.0/0 (Build dependencies)
```

## 📊 Monitoramento

### CloudWatch Log Groups
- `/aws/apigateway/lncr-prd-api` - Logs do API Gateway
- `/aws/eks/lncr-prd-eks/cluster` - Logs do EKS
- `/aws/codebuild/lncr-*` - Logs do CodeBuild
- `/aws/lambda/lncr-*` - Logs das Lambda Functions

### Métricas Importantes
- **EKS**: CPU, Memory, Network dos nós
- **API Gateway**: Request count, latency, errors
- **Lambda**: Duration, errors, throttles
- **ALB**: Request count, target health
- **FSx**: IOPS, throughput, storage utilization

### Alertas Recomendados
```
- EKS Node CPU > 80%
- API Gateway 5xx errors > 1%
- Lambda errors > 5%
- EKS Cluster unhealthy
- FSx storage > 90%
```

## 🔧 Troubleshooting

### Problemas Comuns

#### 1. Terraform State Lock
```bash
# Forçar unlock (use com cuidado)
terraform force-unlock LOCK_ID
```

#### 2. EKS Nodes não aparecem
```bash
# Verificar AWS Auth ConfigMap
kubectl get configmap aws-auth -n kube-system -o yaml

# Verificar node groups
aws eks describe-nodegroup --cluster-name lncr-prd-eks --nodegroup-name lncr-prd
```

#### 3. API Gateway 403 Errors
```bash
# Verificar custom authorizer
aws lambda invoke --function-name lncr-prd-custom-authorizer --payload '{}' response.json

# Verificar VPC Link
aws apigatewayv2 get-vpc-links
```

#### 4. OpenVPN não acessível
```bash
# Verificar security group
aws ec2 describe-security-groups --group-names lncr-prd-vpn-sg

# Verificar instância
aws ec2 describe-instances --filters "Name=tag:Name,Values=lncr-openvpn-prd-ec2"
```

#### 5. CodeBuild falha
```bash
# Verificar logs
aws logs describe-log-groups --log-group-name-prefix "/aws/codebuild/github-lncr"

# Verificar IAM permissions
aws iam get-role-policy --role-name lncr-codebuild-role --policy-name lncr-codebuild-policy
```

### Comandos Úteis

#### Terraform
```bash
# Refresh state
terraform refresh -var-file="prd.tfvars"

# Import resource
terraform import aws_instance.example i-1234567890abcdef0

# Show state
terraform show

# List resources
terraform state list
```

#### AWS CLI
```bash
# EKS
aws eks list-clusters
aws eks describe-cluster --name lncr-prd-eks

# ECR
aws ecr describe-repositories
aws ecr get-login-password --region us-east-1

# API Gateway
aws apigatewayv2 get-apis
aws apigatewayv2 get-routes --api-id API_ID
```

#### kubectl
```bash
# Verificar nós
kubectl get nodes -o wide

# Verificar pods
kubectl get pods --all-namespaces

# Verificar services
kubectl get svc --all-namespaces

# Logs
kubectl logs -f deployment/aws-load-balancer-controller -n kube-system
```

## 🧪 Testes

### Validação da Infraestrutura

#### 1. Teste de Conectividade VPC
```bash
# Ping entre subnets
aws ec2 describe-route-tables
aws ec2 describe-nat-gateways
```

#### 2. Teste EKS
```bash
# Verificar cluster
kubectl cluster-info
kubectl get nodes
kubectl get pods -A

# Teste de deployment
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

#### 3. Teste API Gateway
```bash
# Teste endpoint
curl -X GET https://API_ID.execute-api.us-east-1.amazonaws.com/

# Teste com autorização
curl -X GET https://API_ID.execute-api.us-east-1.amazonaws.com/protected \
  -H "Authorization: Bearer TOKEN"
```

#### 4. Teste OpenVPN
```bash
# Verificar serviço
curl -k https://OPENVPN_IP:8080/

# Verificar logs
aws ssm start-session --target INSTANCE_ID
sudo tail -f /var/log/openvpnas.log
```

### Testes Automatizados
```bash
# Terraform validate
terraform validate

# Terraform plan
terraform plan -var-file="prd.tfvars" -detailed-exitcode

# Security scan (opcional)
tfsec .
checkov -f main.tf
```

## 💰 Custos

### Estimativa Mensal (us-east-1)

| Recurso | Tipo | Quantidade | Custo Estimado |
|---------|------|------------|----------------|
| EKS Cluster | Control Plane | 1 | $73.00 |
| EC2 Instances | t3.medium | 1-3 | $30-90 |
| NAT Gateway | Standard | 1 | $45.00 |
| OpenVPN | t4g.small | 1 | $15.00 |
| API Gateway | HTTP v2 | - | $1.00/1M requests |
| ECR | Storage | 10GB | $1.00 |
| FSx OpenZFS | 64GB | 1 | $12.80 |
| Lambda | Requests | 1M | $0.20 |
| CloudWatch | Logs | 10GB | $5.00 |
| **Total Estimado** | | | **~$182-242/mês** |

### Otimização de Custos
- Use Spot Instances para nós EKS não críticos
- Configure lifecycle policies no ECR
- Monitore uso do FSx e ajuste capacidade
- Use Reserved Instances para cargas estáveis
- Configure auto-scaling para EKS nodes

## 🤝 Contribuição

### Como Contribuir

1. **Fork** o repositório
2. **Clone** seu fork
3. **Crie** uma branch para sua feature
4. **Faça** suas alterações
5. **Teste** localmente
6. **Commit** com mensagens descritivas
7. **Push** para sua branch
8. **Abra** um Pull Request

### Padrões de Código

#### Terraform
```hcl
# Use nomes descritivos
resource "aws_security_group" "eks_nodes_sg" {
  name = "${var.prefix_name}-nodes-sg"
  # ...
}

# Sempre use tags
tags = {
  Name        = "resource-name"
  Environment = var.environment_name
  Owner       = "Fiap"
  CostCenter  = "FinOps"
}

# Comente código complexo
# Create VPC endpoint for S3 to avoid NAT Gateway costs
resource "aws_vpc_endpoint" "s3" {
  # ...
}
```

#### Commits
```
feat: add FSx OpenZFS module
fix: correct security group rules for EKS
docs: update README with troubleshooting section
refactor: simplify VPC module structure
```

### Testes Antes do PR
```bash
# Validação
terraform fmt -recursive
terraform validate

# Segurança
tfsec .

# Documentação
terraform-docs markdown table --output-file README.md .
```

## 📚 Referências

### Documentação AWS
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [VPC User Guide](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [API Gateway Developer Guide](https://docs.aws.amazon.com/apigateway/)

### Terraform
- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [Helm Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)

### Ferramentas
- [kubectl](https://kubernetes.io/docs/reference/kubectl/)
- [AWS CLI](https://docs.aws.amazon.com/cli/)
- [Terraform](https://www.terraform.io/docs)

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👥 Equipe

- **FIAP - 11SOAT** - Turma de Pós-graduação
- **Projeto**: Lanches Caieiras (LNCR)
- **Arquitetura**: Cloud-native com Kubernetes

---

**Nota**: Esta documentação é mantida atualizada com as mudanças na infraestrutura. Para dúvidas ou sugestões, abra uma issue no repositório.