output "cluster_name" {
  value = module.eks_cluster_name.cluster_name
}

output "region" {
  value = var.aws_region
}

output "alb_irsa_role_arn" {
  value = module.alb_irsa.iam_role_arn
}