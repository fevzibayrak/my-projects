terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
    github = {
      source = "integrations/github"
      version = "~> 5.0"
    }
  }
}


provider "github" {
 token = "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"
}

provider "aws" {
  region = "us-east-1"
  profile = "cw-training"
}

resource "github_repository" "myrepo" {
  name = "bookstore-api"
  auto_init = true
  visibility = "private"
}

resource "github_branch_default" "main" {
  branch = "main"
  repository = github_repository.myrepo.name
}

variable "files" {
  default = ["bookstore-api.py", "requirements.txt", "Dockerfile", "docker-compose.yml"]
}

resource "github_repository_file" "app-files" {
  for_each = toset(var.files)
  content = file(each.value)
  file = each.value
  repository = github_repository.myrepo.name
  branch = "main"
  commit_message = "managed by terraform"
  overwrite_on_create = true
}

resource "aws_instance" "tf-docker-ec2" {
  ami = "ami-00c39f71452c08778"
  instance_type = "t2.micro"
  key_name = "oliver"
  vpc_security_group_ids = [xxxxxxx]
  tags = {
    Name = "Web server of Bookstore"
  }
  user_data = <<-EOF
          #! /bin/bash
          yum update -y
          yum install docker -y
          systemctl start docker
          systemctl enable docker
          usermod -a -G docker ec2-user
          newgrp docker
          curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
          chmod +x /usr/local/bin/docker-compose
          mkdir -p /home/ec2-user/bookstore-api


  EOF
}