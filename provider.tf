provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks_cluster_name.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
}

#data "aws_eks_cluster_auth" "cluster" {
  #name = module.eks_cluster_name.cluster_name
#}

data "aws_eks_cluster" "eks" {
  name = module.eks_cluster_name.cluster_name
}
