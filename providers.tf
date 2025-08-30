terraform {
  required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = ">= 6.0.0"
      }
    }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2            = "http://localhost:4566"
    eks            = "http://localhost:4566"
    iam            = "http://localhost:4566"
    sts            = "http://localhost:4566"
    s3             = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    ecrpublic      = "http://localhost:4566"
    apigatewayv2   = "http://localhost:4566"
    logs           = "http://localhost:4566"
  }
}

provider "aws" {
  alias                       = "virginia"
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2            = "http://localhost:4566"
    eks            = "http://localhost:4566"
    iam            = "http://localhost:4566"
    sts            = "http://localhost:4566"
    s3             = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    ecrpublic      = "http://localhost:4566"
    apigatewayv2   = "http://localhost:4566"
    logs           = "http://localhost:4566"
  }
}