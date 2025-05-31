resource "aws_ecs_cluster" "backend-cluster" {
  name = "backend-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "gimme-scholarship-api" {
  family                   = "gimme-scholarship-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name  = "gimme-scholarship-api"
      image = "${var.account_id}.dkr.ecr.${var.default_region}.amazonaws.com/gimme-scholarship:latest"
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      secrets = [
        {
          name      = "DB_NAME"
          valueFrom = "${data.aws_secretsmanager_secret.db_credentials.arn}:dbname::"
        },
        {
          name      = "DB_USER"
          valueFrom = "${data.aws_secretsmanager_secret.db_credentials.arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${data.aws_secretsmanager_secret.db_credentials.arn}:password::"
        },
        {
          name      = "DB_HOST"
          valueFrom = "${data.aws_secretsmanager_secret.db_credentials.arn}:host::"
        },
        {
          name      = "DB_PORT"
          valueFrom = "${data.aws_secretsmanager_secret.db_credentials.arn}:port::"
        },
        {
          name      = "CLERK_JWKS_URL"
          valueFrom = aws_ssm_parameter.clerk_jwks_url.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/gimme-scholarship-api"
          awslogs-region        = var.default_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "gimme-scholarship-api" {
  name            = "gimme-scholarship-api"
  cluster         = aws_ecs_cluster.backend-cluster.id
  task_definition = aws_ecs_task_definition.gimme-scholarship-api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.api_tg.arn
    container_name   = "gimme-scholarship-api"
    container_port   = 8080
  }

  network_configuration {
    subnets          = [aws_subnet.public_subnets["backend-1a"].id, aws_subnet.public_subnets["backend-1c"].id]
    security_groups  = [aws_security_group.webapi-sg.id]
    assign_public_ip = true
  }
}

resource "aws_security_group" "webapi-sg" {
  name   = "webapi-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "gimme-scholarship-migrate" {
  family                   = "gimme-scholarship-migrate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name  = "gimme-scholarship-migrate"
      image = "${var.account_id}.dkr.ecr.${var.default_region}.amazonaws.com/gimme-scholarship-migrate:latest"
      secrets = [
        {
          name      = "DB_NAME"
          valueFrom = "${data.aws_secretsmanager_secret.db_credentials.arn}:dbname::"
        },
        {
          name      = "DB_USERNAME"
          valueFrom = "${data.aws_secretsmanager_secret.db_credentials.arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${data.aws_secretsmanager_secret.db_credentials.arn}:password::"
        },
        {
          name      = "DB_HOST"
          valueFrom = "${data.aws_secretsmanager_secret.db_credentials.arn}:host::"
        },
        {
          name      = "DB_PORT"
          valueFrom = "${data.aws_secretsmanager_secret.db_credentials.arn}:port::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/gimme-scholarship-migrate"
          awslogs-region        = var.default_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "gimme-scholarship-migrate" {
  name            = "gimme-scholarship-migrate"
  cluster         = aws_ecs_cluster.backend-cluster.id
  task_definition = aws_ecs_task_definition.gimme-scholarship-migrate.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnets["backend-1a"].id]
    security_groups  = [aws_security_group.ecs-db-sg.id]
    assign_public_ip = true
  }
}

resource "aws_security_group" "ecs-db-sg" {
  name   = "ecs-db-sg"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "gimme-scholarship-fetch" {
  family                   = "gimme-scholarship-fetch"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name  = "gimme-scholarship-fetch"
      image = "${var.account_id}.dkr.ecr.${var.default_region}.amazonaws.com/gimme-scholarship-fetch:latest"
      secrets = [
        {
          name      = "DB_NAME"
          valueFrom = "${data.aws_secretsmanager_secret.db_credentials.arn}:dbname::"
        },
        {
          name      = "DB_USER"
          valueFrom = "${data.aws_secretsmanager_secret.db_credentials.arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${data.aws_secretsmanager_secret.db_credentials.arn}:password::"
        },
        {
          name      = "DB_HOST"
          valueFrom = "${data.aws_secretsmanager_secret.db_credentials.arn}:host::"
        },
        {
          name      = "DB_PORT"
          valueFrom = "${data.aws_secretsmanager_secret.db_credentials.arn}:port::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/gimme-scholarship-fetch"
          awslogs-region        = var.default_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "gimme-scholarship-fetch" {
  name            = "gimme-scholarship-fetch"
  cluster         = aws_ecs_cluster.backend-cluster.id
  task_definition = aws_ecs_task_definition.gimme-scholarship-fetch.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnets["backend-1a"].id, aws_subnet.public_subnets["backend-1c"].id]
    security_groups  = [aws_security_group.ecs-db-sg.id]
    assign_public_ip = true
  }
}
