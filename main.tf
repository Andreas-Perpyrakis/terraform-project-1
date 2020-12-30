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
