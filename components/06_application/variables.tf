variable "ecs_sg_name" {
  default = "ecs-demo-sg"
}

variable "alb_sg_name" {
  default = "ecs-demo-elb-sg"
}

variable "s3_bucket_name_alb_log_api" {
  default = "ecs-demo-bucket-tatsukoni"
}

# https://hodalog.com/resolve-the-problem-of-accessing-denied-from-alb-to-s3/
variable "aws_alb_region_id" {
  default = "582318560864"
}

variable "alb_name" {
  default = "ecs-demo-elb"
}

variable "alb_target_group_name" {
  default = "ecs-demo-elb-target-group"
}

variable "ecs_cluster_name" {
  default = "ecs-demo"
}

variable "ecs_task_definition_name" {
  default = "ecs-demo-task-api"
}

variable "fargate_cpu" {
  default = "256"
}

variable "fargate_memory" {
  default = "512"
}

# コンテナ定義系
variable "container_php-fpm_name" {
  default = "fpm"
}

variable "container_nginx_name" {
  default = "nginx"
}

variable "container_nginx_port" {
  default = 80
}

# ECSサービス系
variable "ecs_service_name" {
  default = "ecs-demo-service-api"
}
