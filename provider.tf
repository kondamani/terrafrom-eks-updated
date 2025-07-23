provider "aws" {
  region = var.aws_region

}

provider "kubernetes" {
  host                   = module.eks_cluster_name.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(module.eks_cluster_name.cluster_certificate_authority_data)
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster_name.cluster_name

}


