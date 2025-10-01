#========================================================================================#
#                                FSX OPENZFS FILESYSTEM                                 #
#========================================================================================#

resource "aws_fsx_openzfs_file_system" "main" {
  storage_capacity                = var.storage_capacity
  subnet_ids                      = var.subnet_ids
  deployment_type                 = var.deployment_type
  throughput_capacity             = var.throughput_capacity
  security_group_ids              = length(var.security_group_ids) > 0 ? var.security_group_ids : [aws_security_group.fsx_sg[0].id]
  automatic_backup_retention_days = var.automatic_backup_retention_days
  copy_tags_to_backups            = var.copy_tags_to_backups
  copy_tags_to_volumes            = var.copy_tags_to_volumes

  root_volume_configuration {
    nfs_exports {
      client_configurations {
        clients = "*"
        options = ["rw", "crossmnt", "no_root_squash"]
      }
    }
  }

  tags = {
    Name        = "${var.prefix_name}-${var.environment_name}-fsx-openzfs"
    Environment = var.environment_name
    Owner       = "Fiap"
    CostCenter  = "FinOps"
  }
}

#========================================================================================#
#                                SECURITY GROUP                                         #
#========================================================================================#

resource "aws_security_group" "fsx_sg" {
  count = length(var.security_group_ids) == 0 ? 1 : 0

  name_prefix = "${var.prefix_name}-fsx-openzfs-sg"
  description = "Security group for FSx OpenZFS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 111
    to_port     = 111
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "NFS portmapper TCP"
  }

  ingress {
    from_port   = 111
    to_port     = 111
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "NFS portmapper UDP"
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "NFS"
  }

  ingress {
    from_port   = 20001
    to_port     = 20003
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "FSx OpenZFS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.prefix_name}-fsx-openzfs-sg"
    Environment = var.environment_name
    Owner       = "Fiap"
    CostCenter  = "FinOps"
  }
}