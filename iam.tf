### for bastion(EC2)
data "aws_iam_policy" "ssmManagedPolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "bastion" {
  name = "bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion" {
  role       = aws_iam_role.bastion.name
  policy_arn = data.aws_iam_policy.ssmManagedPolicy.arn
}

### for ECS
# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_basic_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_secretsmanager_access" {
  name = "ecs-secretsmanager-access"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "kms:Decrypt"
        ]
        Resource = ["arn:aws:secretsmanager:${var.default_region}:${var.account_id}:secret:rds/gimme-scholarship/password-*"]
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_ssm_readable" {
  name = "ssm-read-policy-for-ecs-task"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParameterByPath"
        ]
        Resource = [
          "arn:aws:ssm:${var.default_region}:${var.account_id}:parameter/${var.project}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_ssm_readable" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_ssm_readable.arn
}
