#!/bin/bash
#Script de inicialização do ambiente local da aplicação
BIN=$PWD
HELM_RUN_PATH="iac/kubernetes/"
ENV_FILE="$BIN/.env"
DOCKER_BUILD_PATH="$BIN/lncr-app"
NAMESPACE="ns-lncr"
APP_NAME="lanches-caieiras"

# Função para validar se existe o arquivo .env no diretório
validate_env_file() {
    if [ ! -f "$ENV_FILE" ]; then
        echo "ERRO: Arquivo .env não encontrado no diretório $ENV_FILE"
        echo "Por favor, revise instruções para criar um .env válido"
        exit 1
    fi
    echo "Arquivo .env encontrado em $ENV_FILE"
}

# Função para validar se todas as variáveis necessárias estão presentes no .env
validate_env_variables() {
    local env_file="$ENV_FILE"
    local required_vars=(
        "POSTGRES_URL"
        "POSTGRES_USER"
        "POSTGRES_PASSWORD"
        "MERCADOPAGO_CLIENT_ID"
        "MERCADOPAGO_SECRET_ID"
        "MERCADOPAGO_POS_ID"
        "OAUTH_TOTEM_CLIENT_ID"
        "OAUTH_TOTEM_CLIENT_SECRET"
        "OAUTH_ADMIN_CLIENT_ID"
        "OAUTH_ADMIN_CLIENT_SECRET"
    )

    echo "Validando variáveis do arquivo .env..."

    local errors=0
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" "$env_file" 2>/dev/null; then
            echo "✗ $var (não encontrada)"
            ((errors++))
        elif [ -z "$(grep "^${var}=" "$env_file" | cut -d'=' -f2-)" ]; then
            echo "✗ $var (vazia)"
            ((errors++))
        else
            echo "✓ $var"
        fi
    done

    if [ $errors -gt 0 ]; then
        echo "ERRO: $errors variável(eis) com problema no arquivo .env"
        exit 1
    fi
    echo "✓ Todas as variáveis estão corretas no arquivo .env"
}

# Função para exportar as variáveis do .env
export_env_variables() {
    echo "Exportando variáveis do arquivo .env..."
    # Usar sed para remover espaços em branco no final das linhas e linhas vazias
    while IFS= read -r line; do
        # Pular linhas vazias e comentários
        if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
            # Remover espaços em branco no final da linha
            line=$(echo "$line" | sed 's/[[:space:]]*$//')
            export "$line"
        fi
    done < "$ENV_FILE"
    echo "✓ Variáveis exportadas com sucesso"
}

# Função para validar se kubectl está instalado
validate_kubectl() {
    echo "Verificando se kubectl está disponível..."

    if command -v kubectl &> /dev/null; then
        echo "✓ kubectl está instalado"

        # Verificar se kubectl consegue se conectar a um cluster
        if kubectl cluster-info &> /dev/null; then
            echo "✓ kubectl conectado a um cluster"
        else
            echo "⚠ kubectl instalado mas não conectado a nenhum cluster"
        fi
    else
        echo "ERRO: kubectl não encontrado!"
        echo "kubectl é necessário para gerenciar clusters Kubernetes."
        echo "Por favor, instale kubectl: https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi
    echo "✓ kubectl validado"
}

# Função para validar se helm está instalado
validate_helm() {
    echo "Verificando se helm está disponível..."

    if command -v helm &> /dev/null; then
        echo "✓ helm está instalado"

        # Verificar a versão do helm
        local helm_version=$(helm version --short 2>/dev/null)
        if [ $? -eq 0 ]; then
            echo "✓ helm versão: $helm_version"
        fi
    else
        echo "ERRO: helm não encontrado!"
        echo "helm é necessário para gerenciar aplicações Kubernetes."
        echo "Por favor, instale helm: https://helm.sh/docs/intro/install/"
        exit 1
    fi

    echo "✓ helm validado"
}

# Função para validar se Docker está instalado
validate_docker() {
    echo "Verificando se Docker está disponível..."

    if command -v docker &> /dev/null; then
        echo "✓ Docker está instalado"

        # Verificar se Docker está rodando
        if docker info &> /dev/null; then
            echo "✓ Docker está rodando"
        else
            echo "ERRO: Docker está instalado mas não está rodando!"
            echo "Por favor, inicie o Docker Desktop ou o serviço Docker."
            exit 1
        fi

        # Verificar a versão do Docker
        local docker_version=$(docker --version 2>/dev/null)
        if [ $? -eq 0 ]; then
            echo "✓ $docker_version"
        fi
    else
        echo "ERRO: Docker não encontrado!"
        echo "Docker é necessário para construir e executar containers."
        echo "Por favor, instale Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi

    echo "✓ Docker validado"
}

# Função para fazer o build da imagem Docker
build_docker_image() {
    echo "Construindo imagem Docker..."
    cd "$DOCKER_BUILD_PATH"
    echo "Executando build da imagem lanches-caieiras:latest..."
    if docker build -f app/Dockerfile -t lanches-caieiras:latest .; then
        echo "✓ Imagem Docker construída com sucesso: lanches-caieiras:latest"
    else
        echo "ERRO: Falha ao construir a imagem Docker"
        exit 1
    fi
    # Voltar para o diretório original
    cd "$BIN"
}

# Função para iniciar a aplicação com Helm
helm_install() {
    echo "Instalando aplicação com Helm..."

    # Verificar se o diretório do Helm Chart existe
    if [ ! -d "$HELM_RUN_PATH" ]; then
        echo "ERRO: Diretório do Helm Chart não encontrado: $HELM_RUN_PATH"
        exit 1
    fi

    # Verificar se o Chart.yaml existe
    if [ ! -f "$HELM_RUN_PATH/Chart.yaml" ]; then
        echo "ERRO: Chart.yaml não encontrado em $HELM_RUN_PATH"
        exit 1
    fi

    echo "Executando helm install para aplicação $APP_NAME no namespace $NAMESPACE..."

    if helm install $APP_NAME $HELM_RUN_PATH --namespace $NAMESPACE --create-namespace \
      --set secrets.postgresPassword="$POSTGRES_PASSWORD" \
      --set secrets.postgresUser="$POSTGRES_USER" \
      --set secrets.mercadopagoClientId="$MERCADOPAGO_CLIENT_ID" \
      --set secrets.mercadopagoSecretId="$MERCADOPAGO_SECRET_ID" \
      --set secrets.mercadopagoPosId="$MERCADOPAGO_POS_ID" \
      --set postgres.password="$POSTGRES_PASSWORD" \
      --set postgres.storage="$PWD/db" \
      --set storage.images.hostPath="$PWD/images" \
      --set storage.database.hostPath="$PWD/data/postgres" \
      --set app.mercadopago.clientId="$MERCADOPAGO_CLIENT_ID" \
      --set app.mercadopago.secretId="$MERCADOPAGO_SECRET_ID" \
      --set app.mercadopago.posId="$MERCADOPAGO_POS_ID"; then
        echo "✓ Aplicação $APP_NAME instalada com sucesso no namespace $NAMESPACE"
        echo "✓ Para verificar o status: kubectl get pods -n $NAMESPACE"
    else
        echo "ERRO: Falha ao instalar a aplicação com Helm"
        exit 1
    fi
}

# Função para verificar se o Helm release já está instalado
validate_helm_release() {
    echo "Verificando se o Helm release '$APP_NAME' já está instalado..."

    if helm list -n $NAMESPACE 2>/dev/null | grep -q "^$APP_NAME\s"; then
        echo "⚠ Helm release '$APP_NAME' já está instalado no namespace '$NAMESPACE'"
        echo "Para atualizar use: helm upgrade $APP_NAME $HELM_RUN_PATH -n $NAMESPACE"
        echo "Para desinstalar use: helm uninstall $APP_NAME -n $NAMESPACE"

        # Perguntar ao usuário o que fazer
        echo ""
        echo "O que deseja fazer?"
        echo "1) Continuar (pular instalação)"
        echo "2) Desinstalar e reinstalar"
        echo "3) Sair"
        read -p "Escolha uma opção (1, 2 ou 3): " choice

        case $choice in
            1)
                echo "✓ Continuando com o release existente..."
                return 0
                ;;
            2)
                echo "Desinstalando release existente..."
                if helm uninstall $APP_NAME -n $NAMESPACE; then
                    echo "✓ Release desinstalado com sucesso"
                    return 1  # Indica que deve prosseguir com a instalação
                else
                    echo "ERRO: Falha ao desinstalar o release"
                    exit 1
                fi
                ;;
            3)
                echo "Saindo..."
                exit 0
                ;;
            *)
                echo "ERRO: Opção inválida. Saindo..."
                exit 1
                ;;
        esac
    else
        echo "✓ Nenhum release '$APP_NAME' encontrado. Prosseguindo com a instalação..."
        return 1  # Indica que deve prosseguir com a instalação
    fi
}

# Chamar as funções de validação
validate_env_file
validate_env_variables
export_env_variables
validate_kubectl
validate_helm
validate_docker
build_docker_image
validate_helm_release
if [ $? -eq 1 ]; then
    helm_install
fi
