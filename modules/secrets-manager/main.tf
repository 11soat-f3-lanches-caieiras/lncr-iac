#========================================================================================#
#                                SECRETS MANAGER                                         #
#========================================================================================#

resource "aws_secretsmanager_secret" "main" {
  name                    = "${var.prefix_name}-${var.environment_name}-sm"
  description             = "Main secrets manager for ${var.prefix_name} ${var.environment_name} environment"
  recovery_window_in_days = var.recovery_window_in_days
  kms_key_id              = var.kms_key_id

  tags = {
    Name        = "${var.prefix_name}-${var.environment_name}-sm"
    Environment = var.environment_name
    Owner       = "Fiap"
    CostCenter  = "FinOps"
  }
}