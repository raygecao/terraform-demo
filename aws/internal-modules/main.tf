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

module "my_vpc" {
  source = "./modules/vpc"
  subnet_cidr_block = var.subnet_cidr_block
  vpc_cidr_block = var.vpc_cidr_block
  available_zone = var.available_zone
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
  vpc_id = module.my_vpc.vpc_id

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
    Name = "internal-module-sg"
  }
}


resource "aws_instance" "my-server" {
  ami                         = data.aws_ami.amazon-linux-image.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = module.my_vpc.subnet_id
  vpc_security_group_ids      = [aws_security_group.my-sg.id]
  availability_zone			  = var.available_zone
  key_name = aws_key_pair.ssh.key_name

  tags = {
    Name = "internal-module-inst"
  }
  user_data_replace_on_change = true


  user_data = file("launch.sh")
}

resource aws_key_pair "ssh" {
  key_name = "internal-module-instance-key"
  public_key = file(var.public_key_path)
}

output "server-ip" {
  value = aws_instance.my-server.public_ip
}

