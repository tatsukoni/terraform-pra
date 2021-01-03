variable "ecs_task_execution_role_name" {
  default = "ecsTaskExecutionRole"
}

variable "ssm_read_for_ssm_policy" {
  default = "SSMReadForECSPolicy"
}
