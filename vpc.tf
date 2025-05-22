locals {
  public_subnets = {
    "subnet-elb-1a" = {
      az         = "${var.default_region}a"
      cidr_block = "10.0.0.0/24"
      tags = {
        Name = "public-subnet-elb-${var.project_name}"
      }
    },
  }

  private_subnets = {
    "subnet-ecs-1a" = {
      az         = "${var.default_region}a"
      cidr_block = "10.0.10.0/24"
      tags = {
        Name = "private-subnet-ecs-${var.project_name}-1a"
      }
    },
    "subnet-rds-1a" = {
      az         = "${var.default_region}a"
      cidr_block = "10.0.20.0/24"
      tags = {
        Name = "private-subnet-rds-${var.project_name}-1a"
      }
    },
    "subnet-ecs-1c" = {
      az         = "${var.default_region}c"
      cidr_block = "10.0.11.0/24"
      tags = {
        Name = "private-subnet-ecs-${var.project_name}-1c"
      }
    },
    "subnet-rds-1c" = {
      az         = "${var.default_region}c"
      cidr_block = "10.0.21.0/24"
      tags = {
        Name = "private-subnet-rds-${var.project_name}-1c"
      }
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_subnets" {
  for_each = local.public_subnets

  vpc_id            = aws_vpc.main.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr_block
  tags              = each.value.tags
}

resource "aws_subnet" "private_subnets" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.main.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr_block
  tags              = each.value.tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}
