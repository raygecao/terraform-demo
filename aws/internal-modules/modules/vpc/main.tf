resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "internal-module-vpc"
  }
}

resource "aws_subnet" "my-subnet" {
  availability_zone = var.available_zone
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.subnet_cidr_block
  tags = {
    Name: "internal-module-subnet"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "internal-module-internet-gateway"
  }
}


resource "aws_route_table" "my-route-table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    Name = "internal-module-route-table"
  }
}

resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-route-table.id
}
