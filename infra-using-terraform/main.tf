terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


locals {
  vpc_id           = "vpc-02387fae1fb7303a1"
  subnet_id        = "subnet-0c298bca95293811e"
  ssh_user         = "ubuntu"
 }

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_security_group" "rajesh" {
  name   = "rajesh_access"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_key_pair" "tf-key-pair" {
# key_name = "tf-key-pair"
# public_key = tls_private_key.rsa.public_key_openssh
# }
# resource "tls_private_key" "rsa" {
# algorithm = "RSA"
# rsa_bits  = 4096
# }
# resource "local_file" "tf-key" {
# content  = tls_private_key.rsa.private_key_pem
# filename = "tf-key-pair"
# }
resource "aws_instance" "nginx" {
  ami                         = "ami-05375ba8414409b07"
  subnet_id                   = "subnet-0c298bca95293811e"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.rajesh.id]
  key_name                    = "devops-project"
 
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo bash -c 'echo your very first web server > /var/www/html/index.html'
    EOF

  tags = {
  Name = "first-ec2-server"
}
connection {
type = "ssh"
user = "ubuntu"
private_key = file("./devops-project.pem")
host = self.public_ip
}

provisioner "remote-exec" {
inline = [
    "sleep 10",
    "sudo apt-get update",
    "curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -",
    "sudo apt install nodejs",
    "git clone https://github.com/rajeshkbajaj/Express.git",
    "cd /home/ubuntu/Express",
    "npm install",
    "cd ./examples/hello-world/",
    "node index.js"
  ]
}

}

output "server_public_ip" {
value = aws_instance.nginx.public_ip
}


