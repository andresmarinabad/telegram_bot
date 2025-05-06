provider "aws" {
  region = "eu-west-1"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "telegram-bot-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/telegram-bot-key.pem"
  file_permission = "0400"
}

data "template_file" "init" {
  template = file("${path.module}/user_data.tpl")

  vars = {
    telegram_bot_token = var.telegram_bot_token
  }
}

resource "aws_launch_template" "telegram_bot_tpl" {
  name_prefix   = "telegram-bot"
  image_id      = "ami-008d05461f83df5b1"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name
  user_data     = base64encode(data.template_file.init.rendered)

  vpc_security_group_ids = [aws_security_group.telegram_bot_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "telegram-bot"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "telegram_bot_asg" {
  name              = "telegram-bot"
  max_size          = 1
  min_size          = 1
  desired_capacity  = 1
  health_check_type = "EC2"
  launch_template {
    id      = aws_launch_template.telegram_bot_tpl.id
    version = "$Latest"
  }

  vpc_zone_identifier = [aws_subnet.public.id]

  tag {
    key                 = "Name"
    value               = "telegram-bot"
    propagate_at_launch = true
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "telegram_bot_sg" {
  name        = "telegram-bot-sg"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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