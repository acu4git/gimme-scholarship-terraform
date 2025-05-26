resource "aws_rds_cluster" "main" {
  cluster_identifier = "${var.project}-aurora-cluster"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.08.2"
}

resource "aws_db_subnet_group" "main" {
  name        = "${var.project}-rds-subnet-group"
  description = "DB subnet group"
  subnet_ids  = [aws_subnet.private_subnets["rds-1a"].id]
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

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = []
  }
}
