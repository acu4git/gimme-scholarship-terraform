data "aws_ssm_parameter" "amzn2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_iam_instance_profile" "bastion-profile" {
  name = "bastion-profile"
  role = aws_iam_role.bastion.name
}

resource "aws_instance" "bastion" {
  ami                  = data.aws_ssm_parameter.amzn2_ami.value
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.bastion-profile.name
  # 踏み台サーバーもとりあえずECSと共存させる
  subnet_id                   = aws_subnet.public_subnets["backend-1a"].id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.bastion.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

resource "aws_security_group" "bastion" {
  name   = "${var.project}-bastion-sg"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
