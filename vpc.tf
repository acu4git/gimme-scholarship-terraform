locals {
  public_subnets = {
    elb-1a = {
      az         = "${var.default_region}a"
      cidr_block = "10.0.0.0/24"
    }
    elb-1c = {
      az         = "${var.default_region}c"
      cidr_block = "10.0.1.0/24"
    }
  }

  private_subnets = {
    ecs-1a = {
      az         = "${var.default_region}a"
      cidr_block = "10.0.10.0/24"
    }
    ecs-1c = {
      az         = "${var.default_region}c"
      cidr_block = "10.0.11.0/24"
    }
    rds-1a = {
      az         = "${var.default_region}a"
      cidr_block = "10.0.20.0/24"
    }
    rds-1c = {
      az         = "${var.default_region}c"
      cidr_block = "10.0.21.0/24"
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

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}
