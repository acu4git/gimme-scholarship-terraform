resource "aws_ecr_repository" "gimme-scholarship-api" {
  name = "${var.project}-api"
  tags = {
    Name = "${var.project}-api"
  }
}

resource "aws_ecr_repository" "gimme-scholarship-task" {
  name = "${var.project}-task"
  tags = {
    Name = "${var.project}-task"
  }
}

resource "aws_ecr_repository" "gimme-scholarship-migrate" {
  name = "${var.project}-migrate"
  tags = {
    Name = "${var.project}-migrate"
  }
}

resource "aws_ecr_repository" "gimme-scholarship-fetch" {
  name = "${var.project}-fetch"
  tags = {
    Name = "${var.project}-fetch"
  }
}
