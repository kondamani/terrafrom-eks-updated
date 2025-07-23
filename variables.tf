variable "aws" {
  description = "AWS Region"
  type        = string
  default = "us-east-1"
}

variable "eks_cluster_name" {
  default = "eks-tera-javaproject"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "node_instance_type" {
  default = "t3.medium"
}

variable "table_name" {
  default = "manis3bucket"
}

variable "dynamodb_table" {
  default = "mani_lockfile"
}

variable "azs" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "alb_service_account_name" {
  default = "aws-load-balancer-controller"
}

variable "alb_service_account_namespace" {
  default = "kube-system"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1" # or your preferred region
}


