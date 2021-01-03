output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "subnet_public1_id" {
  value = aws_subnet.public_1a.id
}

output "subnet_public2_id" {
  value = aws_subnet.public_1c.id
}

output "subnet_private1_id" {
  value = aws_subnet.private_1a.id
}

output "subnet_private2_id" {
  value = aws_subnet.private_1c.id
}

output "aws_eip_nat_gateway_public1_ip" {
  value = aws_eip.nat_gateway_1a.public_ip
}

output "aws_eip_nat_gateway_public2_ip" {
  value = aws_eip.nat_gateway_1c.public_ip
}
