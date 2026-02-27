# Reference existing VPC from Jenkins-TF
locals {
  shared_vpc_id = data.aws_vpc.shared_vpc.id
  shared_igw_id = data.aws_internet_gateway.shared_igw.id
  shared_rt_id  = data.aws_route_table.shared_rt.id
}

# Create Public Subnet 1 for EKS (in shared VPC)
resource "aws_subnet" "public-subnet1" {
  vpc_id                  = local.shared_vpc_id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet-name
  }
}

# Create Public Subnet 2 for EKS (in shared VPC)
resource "aws_subnet" "public-subnet2" {
  vpc_id                  = local.shared_vpc_id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet-name2
  }
}

# Associate Shared Route Table with EKS Subnets
resource "aws_route_table_association" "rt-association1" {
  route_table_id = local.shared_rt_id
  subnet_id      = aws_subnet.public-subnet1.id
}

resource "aws_route_table_association" "rt-association2" {
  route_table_id = local.shared_rt_id
  subnet_id      = aws_subnet.public-subnet2.id
}

# Reference existing Jenkins Security Group for EKS compatibility
# If you need EKS-specific security group rules, create a new one below
resource "aws_security_group" "sg" {
  name   = var.security-group-name
  vpc_id = local.shared_vpc_id
  description = "EKS Security Group"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security-group-name
  }
}
