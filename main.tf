locals {
  vpc_id           = "vpc-02387fae1fb7303a1"
  subnet_id        = "subnet-0c298bca95293811e"
  ssh_user         = "ubuntu"
  key_name         = "devops-project"
  private_key_path = "./devops-project.pem"
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

resource "aws_instance" "nginx" {
  ami                         = "ami-05375ba8414409b07"
  subnet_id                   = "subnet-0c298bca95293811e"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx.id]
  key_name                    = local.key_name

    provisioner "file" {
    source      = "./devops-project.pem"
    destination = "/home/ubuntu//devops-project.pem"
    }

 provisioner "remote-exec" {
    inline = ["sudo apt-get update -y",
              "git clone https://github.com/rajeshkbajaj/Express.git",
              "cd /home/ubuntu/express/examples",
              "sudo apt install nodejs -y",
              "sudo apt install npm -y",
              "npm install",
              "cd ./examples/hello-world/",
              "node index.js"
              ]
  }
    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key_path = ./devops-project.pem
      host        = aws_instance.nginx.public_ip
    }
    
  }
}



