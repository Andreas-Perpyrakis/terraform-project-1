provider "aws" {
  region = "us-east-1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

variable "aws_access_key" {}

variable "aws_secret_key" {}

resource "aws_instance" "my_server" {
  ami           = "ami-0885b1f6bd170450c"
  instance_type = "t3.micro"
    tags = {
    Name = "My_terraform_Server"
  }
}

resource "aws_vpc" "andreas_vpc" {
  cidr_block = "10.0.0.0/16"
    tags = {
    Name = "Production_vpc"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.andreas_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "pro-subnet"
  }
}
