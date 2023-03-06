terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.56.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.available_zone]
  public_subnets  = [var.subnet_cidr_block]

  tags = {
    Name: "external-modules-vpc"
  }
  public_subnet_tags = {
    Name: "external-modules-subnet-1"
  }

}


data "aws_ami" "amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "my-sg" {
  name   = "my-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "external-module-sg"
  }
}


resource "aws_instance" "my-server" {
  ami                         = data.aws_ami.amazon-linux-image.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.my-sg.id]
  availability_zone			  = var.available_zone
  key_name = aws_key_pair.ssh.key_name

  tags = {
    Name = "external-module-inst"
  }
  user_data_replace_on_change = true

  user_data = file("launch.sh")
}

resource aws_key_pair "ssh" {
  key_name = "external-module-instance-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCq36lhlvScF3zK17uMC1KnFVp1d6WxSgo7EkdPx8eMXzVFZv22WAbXn/4tQgM30o+m8WQhG/gXZV+SKU1ZF6F0Xsub3wlaJiX6j3tA5qYvBpUsY8o2jBgGmcnfM+vHwXtDaS08deswHm0tpzwlhuYR5okf8tHsPSt0LPAqNLZ0PiwLuA1LxcSFE8wLUlq4HzVsiTGcnSfdDBrF1Aq3mvNuOZSJWNiuS6mz7t7/o8i/glsWH6rVYnmUupfyP8izSutRmsydenHYDWrZOb6+BGyUihpEhOioPmCT4w3Mi4i/OdcpyiQa76EcPg/5191LZxmyokt+HROaAVpdESAZU6Pl 1812911733@qq.com"
}

output "server-ip" {
  value = aws_instance.my-server.public_ip
}

