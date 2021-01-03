# Provider
provider "aws" {
  region  = "ap-northeast-1"
}

# データベースパスワード
resource "aws_ssm_parameter" "ssm_database_password" {
  name        = "/database/password"
  description = "database master password"
  type        = "SecureString"
  value       = "Change_me_on_AWS_console" # コンソール上で手動で変える

  lifecycle {
    ignore_changes = [value]
  }
}
