# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    serverscom = {
      source = "serverscom/serverscom"
      version = "0.4.2"
    }
#    random = {
#      source  = "hashicorp/random"
#      version = "3.4.3"
#    }
  }
  #required_version = ">= 1.1.0"
}

provider "aws" {
  region = "eu-central-1"
}

tags = {
  Name = "complete-cd-attempt"
}

#resource "random_pet" "sg" {}

# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }

resource "aws_instance" "web" {
  ami                    = "ami-04f1b917806393faa" #this is now hard coded, need to figure out how to do the aboe way that is commented out atm
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum upgrade
                sudo yum install -y git htop wget
                echo "Hello, World!" > hello.txt
                sudo -u ec2-user sh -c 'echo "Hello, World!" > hello.txt
                sudo -u ec2-user sh -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash'
              EOF
}
              # #!/bin/bash
              # apt-get update
              # apt-get install -y apache2
              # sed -i -e 's/80/8080/' /etc/apache2/ports.conf
              # echo "Hello World" > /var/www/html/index.html
              # systemctl restart apache2

resource "aws_security_group" "web-sg" {
#  name = "${random_pet.sg.id}-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}
