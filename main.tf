provider "aws" {
  region = "us-east-1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

variable "aws_access_key" {}

variable "aws_secret_key" {}

# resource "aws_instance" "my_server" {
#   ami           = "ami-0885b1f6bd170450c"
#   instance_type = "t3.micro"
#     tags = {
#     Name = "My_terraform_Server"
#   }
# }

resource "aws_vpc" "andreas_vpc" {
  cidr_block = "10.0.0.0/16"
    tags = {
    Name = "Production_vpc"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.andreas_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "pro-subnet"
  }
}

resource "aws_route_table_association" "associate" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-rr.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.andreas_vpc.id

}

resource "aws_route_table" "prod-rr" {
  vpc_id = aws_vpc.andreas_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod"
  }
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.andreas_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
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

  tags = {
    Name = "allow_web"
  }
}


  resource "aws_network_interface" "web_server_nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
  }

  resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web_server_nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on       = [aws_internet_gateway.gw]
  }

  resource "aws_instance" "Ubuntu_server" {
    ami           = "ami-0885b1f6bd170450c"
    instance_type = "t3.micro"
    availability_zone = "us-east-1a"
    key_name = "andy1"
    user_data = "${file("install.sh")}"

    

    network_interface {
        device_index = 0 
        network_interface_id = aws_network_interface.web_server_nic.id
    } 
  }
               
