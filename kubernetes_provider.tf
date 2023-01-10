data "aws_eks_cluster" "this" {
  count = var.create ? 1 : 0
  name = aws_eks_cluster.this[0].name
  depends_on = [
    module.eks_managed_node_group
  ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this[0].endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this[0].certificate_authority.0.data)

  dynamic "exec" {
    for_each = var.create ? [1] : []
    content {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.this[0].name]
    }
  }
}
