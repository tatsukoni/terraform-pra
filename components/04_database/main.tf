# Provider
provider "aws" {
  region  = "ap-northeast-1"
}

# DB Subnet Group
resource "aws_db_subnet_group" "db_subnet" {
  name = var.database_subnet_group_name

  subnet_ids = [
    data.terraform_remote_state.network.outputs.subnet_private1_id,
    data.terraform_remote_state.network.outputs.subnet_private2_id,
  ]

  tags = {
    "Name" = var.database_subnet_group_name
  }
}

# DB Security Group
module "db_sg" {
  source = "../../modules/security_group"
  name = var.database_sg_name
  port = 3306
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr_block] // vpc内のアクセスを許可
}

# DB Parameter Group
resource "aws_db_parameter_group" "mysql" {
  name = var.database_instance_name
  family = var.database_parameter_group_family
}

# DB Instance
resource "aws_db_instance" "mysql_instance" {
  identifier = var.database_instance_name
  engine = var.database_engine
  engine_version = var.database_engine_version
  instance_class = var.database_instance_class
  allocated_storage = 20
  storage_type = "gp2"
  storage_encrypted = true
  name = var.database_name
  username = var.database_master_username
  password = var.database_master_password # apply後変更
  multi_az = true
  publicly_accessible = false
  backup_window = "09:10-09:40"
  backup_retention_period = 30
  maintenance_window = "mon:10:10-mon:10:40"
  auto_minor_version_upgrade = false
  deletion_protection = false # demo用のため、削除保護は無効
  skip_final_snapshot = true # demo用のため、削除時のスナップショット保持は不要
  port = 3306
  apply_immediately = false
  vpc_security_group_ids = [module.db_sg.security_group_id]
  parameter_group_name = aws_db_parameter_group.mysql.name
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name

  lifecycle {
    ignore_changes = [password]
  }
}
