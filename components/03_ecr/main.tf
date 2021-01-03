# Provider
provider "aws" {
  region  = "ap-northeast-1"
}

resource "aws_ecr_repository" "nginx" {
  name = var.repository_name_nginx
}

resource "aws_ecr_lifecycle_policy" "nginx" {
  repository = aws_ecr_repository.nginx.name

  policy = file("lifecycle_policy.json")
}

resource "aws_ecr_repository" "php-fpm" {
  name = var.repository_name_fpm
}

resource "aws_ecr_lifecycle_policy" "php-fpm" {
  repository = aws_ecr_repository.php-fpm.name

  policy = file("lifecycle_policy.json")
}
