resource "aws_cloudwatch_event_rule" "gimme_scholarship_fetch" {
  name                = "${var.project}-fetch-rule"
  schedule_expression = "cron(0 15 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "notify_scholarship_deadline" {
  name                = "${var.project}-notify_scholarship_deadline-rule"
  schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "gimme_scholarship_fetch" {
  rule     = aws_cloudwatch_event_rule.gimme_scholarship_fetch.name
  role_arn = aws_iam_role.ecs_events_role.arn
  arn      = aws_ecs_cluster.backend-cluster.arn

  ecs_target {
    launch_type         = "FARGATE"
    platform_version    = "LATEST"
    task_definition_arn = aws_ecs_task_definition.gimme-scholarship-fetch.arn
    network_configuration {
      subnets          = [aws_subnet.public_subnets["backend-1a"].id, aws_subnet.public_subnets["backend-1c"].id]
      security_groups  = [aws_security_group.ecs-db-sg.id]
      assign_public_ip = true
    }
  }
}

resource "aws_cloudwatch_event_target" "notify_scholarship_deadline" {
  rule     = aws_cloudwatch_event_rule.notify_scholarship_deadline.name
  role_arn = aws_iam_role.ecs_events_role.arn
  arn      = aws_ecs_cluster.backend-cluster.arn
  input    = jsonencode({ "containerOverrides" : [{ "name" : "gimme-scholarship-task", "command" : ["-task", "NOTIFY_SCHOLARSHIP_DEADLINE"] }] })
  ecs_target {
    launch_type         = "FARGATE"
    platform_version    = "LATEST"
    task_definition_arn = aws_ecs_task_definition.gimme-scholarship-task.arn
    network_configuration {
      subnets          = [aws_subnet.public_subnets["backend-1a"].id, aws_subnet.public_subnets["backend-1c"].id]
      security_groups  = [aws_security_group.ecs-db-sg.id]
      assign_public_ip = true
    }
  }
}
