module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  enabled_log_types = ["api", "audit", "authenticator"]

  authentication_mode = "API"

  # EKS Auto Mode
  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }
}


# EKS Access Entry for AWS DevOps Agent
resource "aws_eks_access_entry" "devops_agent" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.devops_agent.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "devops_agent" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.devops_agent.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.devops_agent]
}
