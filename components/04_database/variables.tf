variable "database_subnet_group_name" {
  default = "ecs-demo-db-subnet-group"
}

variable "database_sg_name" {
  default = "ecs-demo-db-sg"
}

variable "database_instance_name" {
  default = "ecs-demo-db"
}

variable "database_parameter_group_family" {
  default = "mysql8.0"
}

variable "database_engine" {
  default = "mysql"
}

variable "database_engine_version" {
  default = "8.0.20"
}

variable "database_name" {
  default = "local"
}

variable "database_instance_class" {
  default = "db.t3.small"
}

variable "database_master_username" {
  default = "admin"
}

variable "database_master_password" {
  default = "samplePassword" # 置き換わる
}
