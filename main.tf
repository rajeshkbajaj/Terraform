locals {
  vpc_id           = "vpc-02387fae1fb7303a1"
  subnet_id        = "subnet-0c298bca95293811e"
  ssh_user         = "ubuntu"
 }

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_security_group" "nginx" {
  name   = "nginx_access"
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

resource "aws_key_pair" "ec2-keypair" {
  key_name   = "authorized_keys"
  public_key = "sh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmIN4kybSZ3kd+rwX8QoyPui4EOMZEeFbP/BpBZ1A15cyQ1vWgQLRlyr41MKIjfFa6Nrlf3H+GiTbsAjYicpz2uXzsrOOQC+1aT7vK4RcXSjPvxtZgJw4BMwbES0j492akqtXb9fP5uEumt3rkNhmkb0olFEqeEsB1qFXbruTFbiNhyfybdkfTyZ4qQOUdm+3ZSVDJUanGTI2NqyVzNeGtQtBiEDFTP0I6sEjAckEetr8IA0LP5VF1GTWIZIxn002pcln8Xts/tYZ1r3FoMuI6BtDcKTkm3fpQzLc0NZEG/bB/BahMUhwTfO/nYA9NRjAwoHLlv23jveQ4cDjb7tGj devops-project"
}

resource "aws_instance" "nginx" {
  ami                         = "ami-05375ba8414409b07"
  subnet_id                   = "subnet-0c298bca95293811e"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx.id]
  key_name                    = aws_key_pair.ec2-keypair.key_name
  
  }




