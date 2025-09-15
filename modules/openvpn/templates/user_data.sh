#!/bin/bash

# Atualização do sistema
sudo apt-get update
sudo apt-get upgrade -y

# Install CloudWatch Agent
wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/arm64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start   a

# Instalação de dependências
sudo apt install -y sqlite3 apt-transport-https ca-certificates curl software-properties-common

# Adicionar repositório do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Verificar versão do Docker
sudo docker --version

# Adicionar o usuário ao grupo 'docker'
sudo usermod -aG docker ubuntu

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar versão do Docker Compose
docker-compose --version

# Habilitar e iniciar o serviço Docker
sudo systemctl enable docker
sudo systemctl start docker

# Clonar repositório e iniciar contêineres na home do usuário 'ubuntu'
sudo -u ubuntu git clone https://github.com/d3vilh/openvpn-server /home/ubuntu/openvpn-server

admin_username="${admin_username}"
admin_password="${admin_password}"
prefix_name="${prefix_name}"

IP=$(hostname -I | awk '{print $1}')
export IP

# Entrar no diretorio do repositorio
cd /home/ubuntu/openvpn-server

# Editar o arquivo docker-compose.yml
sudo sed -i "s/OPENVPN_ADMIN_USERNAME=admin/OPENVPN_ADMIN_USERNAME=${admin_username}/" /home/ubuntu/openvpn-server/docker-compose.yml
sudo sed -i "s/OPENVPN_ADMIN_PASSWORD=gagaZush/OPENVPN_ADMIN_PASSWORD=${admin_password}/" /home/ubuntu/openvpn-server/docker-compose.yml

# Editar o arquivo client.conf para adicionar o ip da instância no servidor openvpn
sudo sed -i 's/remote 127.0.0.1 1194 udp/remote $IP 1194 udp/' /home/ubuntu/openvpn-server/config/client.conf

# Editar o arquivo server.conf para adicionar a criptografia no servidor openvpn
sudo sed -i '/dh pki\/dh.pem/a tls-crypt pki/ta.key' /home/ubuntu/openvpn-server/server.conf

# Editar o arquivo easy-rsa.varsa
sudo sed -i "s/\"UA\"/\"BR\"/" /home/ubuntu/openvpn-server/config/easy-rsa.vars
sudo sed -i "s/\"KY\"/\"SP\"/" /home/ubuntu/openvpn-server/config/easy-rsa.vars
sudo sed -i "s/\"Kyiv\"/\"Mogi das Cruzes\"/" /home/ubuntu/openvpn-server/config/easy-rsa.vars
sudo sed -i "s/\"SweetHome\"/\"${prefix_name}\"/" /home/ubuntu/openvpn-server/config/easy-rsa.vars
sudo sed -i "s/\"sweet@home.net\"/\"nome@${prefix_name}.com.br\"/" /home/ubuntu/openvpn-server/config/easy-rsa.vars
sudo sed -i "s/\"MyOrganizationalUnit\"/\"DevOps\"/" /home/ubuntu/openvpn-server/config/easy-rsa.vars

sudo docker compose up -d

# Mensagem de conclusão
echo "Instalação e configuração concluídas!"