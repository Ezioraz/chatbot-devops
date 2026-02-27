# Reference existing VPC created by Jenkins-TF
data "aws_vpc" "shared_vpc" {
  filter {
    name   = "tag:Name"
    values = ["Jenkins-vpc"]
  }
}

# Reference existing Internet Gateway
data "aws_internet_gateway" "shared_igw" {
  filter {
    name   = "tag:Name"
    values = ["Jenkins-igw"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.shared_vpc.id]
  }
}

# Reference existing Route Table
data "aws_route_table" "shared_rt" {
  filter {
    name   = "tag:Name"
    values = ["Jenkins-route-table"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.shared_vpc.id]
  }
}

# Reference existing Security Group
data "aws_security_group" "jenkins_sg" {
  filter {
    name   = "tag:Name"
    values = ["Jenkins-sg"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.shared_vpc.id]
  }
}
