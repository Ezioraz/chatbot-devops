terraform {
  backend "s3" {
    bucket         = "eks-tf-state-javid"
    region         = "ap-south-1"
    key            = "eks/dev/terraform.tfstate"
    dynamodb_table = "Lock-Files"
    encrypt        = true
  }
 
}
