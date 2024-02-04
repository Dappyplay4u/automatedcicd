#configure aws profile
provider "aws" {
  region  = "us-east-1"
  profile = "mainuser"
}