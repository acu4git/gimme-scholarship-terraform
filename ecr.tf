resource "aws_ecr_repository" "gimme-scholarship" {
  name = var.project
  tags = {
    Name = var.project
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

resource "aws_ecr_repository" "gimme-scholarship-scraping" {
  name = "${var.project}-scraping"
  tags = {
    Name = "${var.project}-scraping"
  }
}
