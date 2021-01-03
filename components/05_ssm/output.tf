output "ssm_database_password_name" {
  value = "${aws_ssm_parameter.ssm_database_password.name}"
}
