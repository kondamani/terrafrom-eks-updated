########################################
# main.tf (Updated with ALB IRSA Setup)
########################################

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name = "eks-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name = "eks-vpc"
  }
}

# EKS Cluster Module
module "eks_cluster_name" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.4"
  cluster_name    = var.eks_cluster_name
  cluster_version = 1.31
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = [var.node_instance_type]
    }
  }

  tags = {
    Name = var.eks_cluster_name
  }
}

# IRSA for AWS Load Balancer Controller
module "alb_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix = "alb-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn = module.eks_cluster_name.oidc_provider_arn
      namespace_service_accounts = [
        "${var.alb_service_account_namespace}:${var.alb_service_account_name}"
      ]
    }
  }
  /*module "s3" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = var.table_name
  version = "4.0.0"

  tags = {
    Name        = var.table_name
    Environment = "dev"
  }

}

module "dynamodb-table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "3.0.0"

  name         = var.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]
}*/

  tags = {
    Name = "alb-irsa-role"
  }
}


# Kubernetes Service Account for ALB Controller
resource "kubernetes_service_account" "alb_sa" {
  metadata {
    name      = var.alb_service_account_name
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.alb_irsa.iam_role_arn
    }
  }

  depends_on = [module.alb_irsa]
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = module.eks_cluster_name.eks_managed_node_groups["default"].iam_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      {
        rolearn  = module.alb_irsa.iam_role_arn
        username = "admin"
        groups   = ["system:masters"]
      }
    ])
  }

  depends_on = [module.eks_cluster_name]
}
