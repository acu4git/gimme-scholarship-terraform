resource "aws_ecs_cluster" "backend-cluster" {
  name = "backend-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
