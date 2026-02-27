provider "aws" {
  region = "ap-south-1"
}

# VPC
resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Jenkins-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = {
    Name = "Jenkins-igw"
  }
}

# Public Subnet
resource "aws_subnet" "jenkins_subnet" {
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Jenkins-subnet"
  }
}

# Route Table
resource "aws_route_table" "jenkins_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }

  tags = {
    Name = "Jenkins-route-table"
  }
}

resource "aws_route_table_association" "jenkins_assoc" {
  subnet_id      = aws_subnet.jenkins_subnet.id
  route_table_id = aws_route_table.jenkins_rt.id
}

# Security Group
resource "aws_security_group" "jenkins_sg" {
  name   = "Jenkins-sg"
  vpc_id = aws_vpc.jenkins_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
  description = "SonarQube"
  from_port   = 9000
  to_port     = 9000
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
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
    Name = "Jenkins-sg"
  }
}

# Jenkins EC2
resource "aws_instance" "jenkins" {
  ami                         = "ami-007e51e00fe1e2173" # Verify for ap-south-1
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.jenkins_subnet.id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true
  key_name                    = "chatbotui"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y

              # Install Java 17 (Required for Jenkins)
              yum install -y java-17-amazon-corretto

              # Install Jenkins
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              yum install -y jenkins

              systemctl daemon-reload
              systemctl enable jenkins
              systemctl start jenkins

              # Install Docker
              amazon-linux-extras install docker -y
              systemctl start docker
              systemctl enable docker

              # Add users to docker group
              usermod -aG docker ec2-user
              usermod -aG docker jenkins

              # Pull and Run SonarQube container
              docker pull sonarqube:lts
              docker run -d --name sonarqube \
                -p 9000:9000 \
                sonarqube:lts
              EOF



  tags = {
    Name = "Jenkins-Server"
  }
}

# Outputs for reference by other modules
output "vpc_id" {
  value       = aws_vpc.jenkins_vpc.id
  description = "Shared VPC ID"
}

output "vpc_cidr_block" {
  value       = aws_vpc.jenkins_vpc.cidr_block
  description = "Shared VPC CIDR block"
}

output "jenkins_subnet_id" {
  value       = aws_subnet.jenkins_subnet.id
  description = "Jenkins Subnet ID"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.jenkins_igw.id
  description = "Internet Gateway ID"
}

output "route_table_id" {
  value       = aws_route_table.jenkins_rt.id
  description = "Route Table ID"
}

output "jenkins_sg_id" {
  value       = aws_security_group.jenkins_sg.id
  description = "Jenkins Security Group ID"
}
