# Provider
provider "aws" {
  region  = "ap-northeast-1"
}

# vpc
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "ecs-demo-vpc"
  }
}

# public subnet
resource "aws_subnet" "public_1a" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_public1_cidr_block
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"

  tags = {
    "Name" = "ecs-demo-public-1a"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_public2_cidr_block
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1c"

  tags = {
    "Name" = "ecs-demo-public-1c"
  }
}

# private subnet
resource "aws_subnet" "private_1a" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_private1_cidr_block
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"

  tags = {
    "Name" = "ecs-demo-private-1a"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_private2_cidr_block
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"

  tags = {
    "Name" = "ecs-demo-private-1c"
  }
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "ecs-demo-igw"
  }
}

# public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "ecs-demo-public-table"
  }
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# EIP for Nat
resource "aws_eip" "nat_gateway_1a" {
  vpc = true
  depends_on = [aws_internet_gateway.igw]

  tags = {
    "Name" = "ecs-demo-eip-1a"
  }
}

resource "aws_eip" "nat_gateway_1c" {
  vpc = true
  depends_on = [aws_internet_gateway.igw]

  tags = {
    "Name" = "ecs-demo-eip-1c"
  }
}

# NAT
resource "aws_nat_gateway" "nat_1a" {
  allocation_id = aws_eip.nat_gateway_1a.id
  subnet_id     = aws_subnet.public_1a.id
  depends_on = [aws_internet_gateway.igw]

  tags = {
    "Name" = "ecs-demo-nat-gw-1a"
  }
}

resource "aws_nat_gateway" "nat_1c" {
  allocation_id = aws_eip.nat_gateway_1c.id
  subnet_id     = aws_subnet.public_1c.id
  depends_on = [aws_internet_gateway.igw]

  tags = {
    "Name" = "ecs-demo-nat-gw-1c"
  }
}

# private route table
resource "aws_route_table" "private_1a" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "ecs-demo-private-table-1a"
  }
}

resource "aws_route_table" "private_1c" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "ecs-demo-private-table-1c"
  }
}

resource "aws_route" "private_1a" {
  route_table_id = aws_route_table.private_1a.id
  nat_gateway_id = aws_nat_gateway.nat_1a.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private_1c" {
  route_table_id = aws_route_table.private_1c.id
  nat_gateway_id = aws_nat_gateway.nat_1c.id
  destination_cidr_block = "0.0.0.0/0"
}

# SubnetとRouteTableの関連付け
resource "aws_route_table_association" "public1" {
  subnet_id = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1" {
  subnet_id = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_1a.id
}

resource "aws_route_table_association" "private2" {
  subnet_id = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private_1c.id
}
