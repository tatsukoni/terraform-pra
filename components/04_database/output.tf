output "database_endpoint" {
  value = "${aws_db_instance.mysql_instance.endpoint}"
}

output "database_name" {
  value = "${aws_db_instance.mysql_instance.name}"
}

output "database_username" {
  value = "${aws_db_instance.mysql_instance.username}"
}
