output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "configure_kubectl" {
  description = "Configure kubectl command"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}


output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

output "agent_space_id" {
  description = "DevOps Agent Space ID"
  value       = awscc_devopsagent_agent_space.main.agent_space_id
}

output "agent_space_arn" {
  description = "DevOps Agent Space ARN"
  value       = awscc_devopsagent_agent_space.main.arn
}

output "devops_operator_role_arn" {
  description = "IAM role ARN for DevOps Operator App"
  value       = aws_iam_role.devops_operator.arn
}

output "investigation_group_id" {
  description = "Investigation Group ID for ALB 5XX errors"
  value       = awscc_devopsagent_investigation_group.alb_5xx.investigation_group_id
}

output "investigation_group_arn" {
  description = "Investigation Group ARN for ALB 5XX errors"
  value       = awscc_devopsagent_investigation_group.alb_5xx.arn
}
