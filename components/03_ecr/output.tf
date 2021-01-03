output "ecr_repository_uri_nginx" {
  value = aws_ecr_repository.nginx.repository_url
}

output "ecr_repository_uri_php-fpm" {
  value = aws_ecr_repository.php-fpm.repository_url
}
