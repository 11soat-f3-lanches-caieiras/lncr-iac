#!/bin/bash

echo "Iniciando LocalStack..."
docker-compose up -d

echo "Aguardando LocalStack inicializar..."
sleep 10

echo "Limpando cache do Terraform..."
rm -rf .terraform .terraform.lock.hcl

echo "Inicializando Terraform..."
terraform init

echo "Validando configuração..."
terraform validate

echo "Planejando infraestrutura..."
terraform plan -var-file="prd.tfvars"

echo "LocalStack está pronto! Para aplicar:"
echo "terraform apply -var-file='prd.tfvars'"