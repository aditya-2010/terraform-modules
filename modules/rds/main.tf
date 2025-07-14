######################################################
# RDS Module for PostgreSQL Database
######################################################
variable "identifier" {}
variable "db_subnet_group_name" {}
variable "subnet_groups" {}
variable "instance_class" {}
variable "allocated_storage" {}
variable "engine" {}
variable "engine_version" {}
variable "rds_postgres_sg_id" {}
variable "db_username" {}
variable "db_password" {}
variable "db_name" {}
variable "deletion_protection" {}
variable "environment" {}
variable "tags" {}

#########################################
# RDS Outputs
#########################################
output "db_endpoint" {
  value = aws_db_instance.db_instance.endpoint
}

# ######################################################
# # Resources
# ######################################################
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_groups
}

resource "aws_db_instance" "db_instance" {
  identifier                 = var.identifier
  instance_class             = var.instance_class
  allocated_storage          = var.allocated_storage
  maintenance_window         = "Mon:01:00-Mon:04:00"
  backup_window              = "04:00-07:00"
  engine                     = var.engine
  engine_version             = var.engine_version
  username                   = var.db_username
  password                   = var.db_password
  db_name                    = var.db_name
  db_subnet_group_name       = var.db_subnet_group_name
  vpc_security_group_ids     = [var.rds_postgres_sg_id]
  skip_final_snapshot        = true
  apply_immediately          = true
  backup_retention_period    = 30
  deletion_protection        = var.deletion_protection
  storage_encrypted          = true
  auto_minor_version_upgrade = true
  tags                       = var.tags
}
