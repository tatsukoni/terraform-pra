# Provider
provider "aws" {
  region  = "ap-northeast-1"
}

# Security group for ALB
module "alb_sg" {
  source = "../../modules/security_group"
  name = var.alb_sg_name
  port = 80
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  cidr_blocks = ["0.0.0.0/0"] # インターネットから通信可能
}

# Security group for ECS Service
module "ecs_sg" {
  source = "../../modules/security_group"
  name = var.ecs_sg_name
  port = 80
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr_block] // vpc内のアクセスを許可
}

# s3 bucket for ALB log
resource "aws_s3_bucket" "alb_log" {
  bucket        = var.s3_bucket_name_alb_log_api
  
  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = [join("", ["arn:aws:s3:::", aws_s3_bucket.alb_log.id, "/*"])]

    principals {
      type        = "AWS"
      identifiers = [var.aws_alb_region_id]
    }
  }
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

# ALB
resource "aws_lb" "alb" {
  name = var.alb_name
  load_balancer_type = "application"
  internal = false
  idle_timeout = 60
  enable_deletion_protection = false # デモ用なので、削除保護はしない

  subnets = [
    data.terraform_remote_state.network.outputs.subnet_public1_id,
    data.terraform_remote_state.network.outputs.subnet_public2_id
  ]

  access_logs {
    bucket  = aws_s3_bucket.alb_log.id
    enabled = true
  }

  security_groups = [
    module.alb_sg.security_group_id
  ]
}

# ALB target group
resource "aws_lb_target_group" "api" {
  name        = var.alb_target_group_name
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"

  health_check {
    path     = "/healthcheck"
    matcher  = 200
    protocol = "HTTP"
  }

  depends_on = [aws_lb.alb]
}

# ALB Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

# CloudWatchLogs for ECS Container
resource "aws_cloudwatch_log_group" "ecs_nginx" {
  name = "ecs/nginx"
}

resource "aws_cloudwatch_log_group" "ecs_php-fpm" {
  name = "ecs/php-fpm"
}

# ECS Cluster
resource "aws_ecs_cluster" "api" {
  name = var.ecs_cluster_name
}

# ECS Task Definition
resource "aws_ecs_task_definition" "api" {
  family                   = var.ecs_task_definition_name
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = data.terraform_remote_state.iam.outputs.ecs_task_execution_role_arn

  # コンテナ定義
  container_definitions = <<DEFINITION
    [
      {
        "name": "${var.container_php-fpm_name}",
        "image": "${data.terraform_remote_state.ecr.outputs.ecr_repository_uri_php-fpm}:latest",
        "essential": true,
        "workingDirectory": "/var/www",
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-region": "ap-northeast-1",
            "awslogs-stream-prefix": "php-fpm",
            "awslogs-group": "${aws_cloudwatch_log_group.ecs_nginx.name}"
          }
        },
        "secrets": [
          {
            "name": "DB_PASSWORD",
            "valueFrom": "${data.terraform_remote_state.ssm.outputs.ssm_database_password_name}"
          }
        ],
        "environment": [
          {
            "name": "DB_HOST",
            "value": "${data.terraform_remote_state.database.outputs.database_endpoint}"
          },
          {
            "name": "DB_DATABASE",
            "value": "${data.terraform_remote_state.database.outputs.database_name}"
          },
          {
            "name": "DB_USERNAME",
            "value": "${data.terraform_remote_state.database.outputs.database_username}"
          }
        ]
      },
      {
        "name": "${var.container_nginx_name}",
        "image": "${data.terraform_remote_state.ecr.outputs.ecr_repository_uri_nginx}:latest",
        "essential": true,
        "portMappings": [
          {
            "containerPort": ${var.container_nginx_port},
            "hostPort": ${var.container_nginx_port},
            "protocol": "tcp"
          }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-region": "ap-northeast-1",
            "awslogs-stream-prefix": "nginx",
            "awslogs-group": "${aws_cloudwatch_log_group.ecs_php-fpm.name}"
          }
        }
      }
    ]
  DEFINITION
}

# ECS Service
resource "aws_ecs_service" "api" {
  name                              = var.ecs_service_name
  cluster                           = aws_ecs_cluster.api.arn
  task_definition                   = aws_ecs_task_definition.api.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups  = [module.ecs_sg.security_group_id]

    subnets = [
      data.terraform_remote_state.network.outputs.subnet_private1_id,
      data.terraform_remote_state.network.outputs.subnet_private2_id,
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = var.container_nginx_name
    container_port   = var.container_nginx_port
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}
