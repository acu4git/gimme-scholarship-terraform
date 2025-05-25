locals {
  public_subnets = {
    elb-1a = {
      az         = "${var.default_region}a"
      cidr_block = "10.0.0.0/24"
    }
  }

  private_subnets = {
    ecs-1a = {
      az         = "${var.default_region}a"
      cidr_block = "10.0.10.0/24"
    }
    rds-1a = {
      az         = "${var.default_region}a"
      cidr_block = "10.0.20.0/24"
    }
    bastion-1a = {
      az         = "${var.default_region}a"
      cidr_block = "10.0.30.0/24"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block                       = "10.0.0.0/16"
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_subnets" {
  for_each = local.public_subnets

  vpc_id            = aws_vpc.main.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr_block
  tags = {
    Name = "public-subnet-${each.key}"
  }
}

resource "aws_subnet" "private_subnets" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.main.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr_block
  tags = {
    Name = "private-subnet-${each.key}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-rt"
    Type = "public"
  }
}

resource "aws_route_table_association" "public-rt" {
  for_each = local.public_subnets

  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnets[each.key].id
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt"
    Type = "private"
  }
}

resource "aws_route_table_association" "private-rt" {
  for_each = local.private_subnets

  route_table_id = aws_route_table.private-rt.id
  subnet_id      = aws_subnet.private_subnets[each.key].id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route" "public-rt-igw" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
