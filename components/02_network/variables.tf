variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnet_public1_cidr_block" {
  default = "10.0.0.0/24"
}

variable "subnet_public2_cidr_block" {
  default = "10.0.1.0/24"
}

variable "subnet_private1_cidr_block" {
  default = "10.0.2.0/24"
}

variable "subnet_private2_cidr_block" {
  default = "10.0.3.0/24"
}
