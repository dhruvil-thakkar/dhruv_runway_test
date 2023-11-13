# Backend setup
terraform {
  backend "s3" {
    key = "sampleapp.tfstate"
  }
}

# Variable definitions
variable "region" {
  default = "us-east-1"
}

# Provider and access setup
provider "aws" {
  version = "~> 2.0"
  region  = var.region
}

# Data and resources
resource "aws_sqs_queue" "terraform_queue" {
  delay_seconds = 90
}

resource "aws_vpc" "dhruv_test_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "dhruv_test_vpc"
  }
}

resource "aws_subnet" "useast1a_subnet" {
  vpc_id            = aws_vpc.dhruv_test_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "us-east1-a-subnet"
  }
}

resource "aws_subnet" "useast1b_subnet" {
  vpc_id            = aws_vpc.dhruv_test_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "us-east1-b-subnet"
  }
}

resource "aws_subnet" "useast1c_subnet" {
  vpc_id            = aws_vpc.dhruv_test_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "us-east1-c-subnet"
  }
}

resource "aws_internet_gateway" "dhruv_ig" {
  vpc_id = aws_vpc.dhruv_test_vpc.id

  tags = {
    Name = "Dhruv Test IG"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.dhruv_test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dhruv_ig.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.useast1a_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_1_rt_b" {
  subnet_id      = aws_subnet.useast1b_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_1_rt_c" {
  subnet_id      = aws_subnet.useast1c_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.dhruv_test_vpc.id

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
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "http_and_ssh"
  }
}