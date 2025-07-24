terraform {
  backend "s3" {
    bucket = "manis3bucket"
    key = "eks/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "mani_lockfile"
    encrypt = true
    
  }
}
