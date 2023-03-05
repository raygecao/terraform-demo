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

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${terraform.workspace}-vpc"
  }
}

resource "aws_subnet" "my-subnet" {
  availability_zone = var.available_zone
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.subnet_cidr_block
  tags = {
    Name: "${terraform.workspace}-subnet"
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

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "${terraform.workspace}-internet-gateway"
  }
}


resource "aws_route_table" "my-route-table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    Name = "${terraform.workspace}-route-table"
  }
}

resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-route-table.id
}

resource "aws_security_group" "my-sg" {
  name   = "my-sg"
  vpc_id = aws_vpc.my-vpc.id

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
    Name = "${terraform.workspace}-sg"
  }
}


resource "aws_instance" "my-server" {
  ami                         = data.aws_ami.amazon-linux-image.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.my-subnet.id
  vpc_security_group_ids      = [aws_security_group.my-sg.id]
  availability_zone			  = var.available_zone
  key_name = aws_key_pair.ssh.key_name

  tags = {
    Name = "${terraform.workspace}-inst"
  }

  user_data_replace_on_change = true
  user_data = file(terraform.workspace == "dev" ? "guest1.sh" : "guest2.sh")
}

resource aws_key_pair "ssh" {
  key_name = "${terraform.workspace}_instance_key"
  public_key = file(var.public_key_path)
}

output "server-ip" {
  value = aws_instance.my-server.public_ip
}

