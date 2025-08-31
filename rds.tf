resource "aws_db_instance" "mysql-free-tier" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t4g.micro"
  db_name                = var.db_name
  username               = "admin"
  password               = random_password.rds_admin_password.result
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  publicly_accessible    = false
  multi_az               = false
  storage_type           = "gp2"
  skip_final_snapshot    = true
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-rds-subnet-group"
  subnet_ids = [aws_subnet.private_subnets["rds-1a"].id, aws_subnet.private_subnets["rds-1c"].id]
  tags = {
    Name = "db-subnet"
  }
}

resource "aws_security_group" "db-sg" {
  name   = "db-sg"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "db-sg"
  }

  # from EC2
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # from ECS
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs-db-sg.id, aws_security_group.webapi-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
