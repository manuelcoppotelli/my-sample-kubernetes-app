module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.32"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  cluster_enabled_log_types = ["api", "audit", "authenticator"]

  # Encryption managed outside Terraform - cluster already has KMS encryption configured
  # cluster_encryption_config = {
  #   resources        = ["secrets"]
  #   provider_key_arn = "arn:aws:kms:eu-west-1:714007529877:key/03b87cb0-862e-41c3-b217-0dfe10f86169"
  # }

  eks_managed_node_groups = {
    main = {
      name              = "main-nodegroup"
      use_name_prefix   = false
      min_size          = 0
      max_size          = 3
      desired_size      = 0

      instance_types = [var.node_instance_type]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
