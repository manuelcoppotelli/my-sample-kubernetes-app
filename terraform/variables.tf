variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "EKS cluster name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "private_subnets" {
  description = "VPC CIDR block"
  type        = list(string)
}

variable "public_subnets" {
  description = "VPC CIDR block"
  type        = list(string)
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix (e.g., app/my-alb/1234567890abcdef)"
  type        = string
}

variable "ecr_repo_name" {
  description = "ECR repository name"
  type        = string
}

variable "agent_space_name" {
  description = "Name of the DevOps Agent Space"
  type        = string
}

variable "agent_space_description" {
  description = "Description of the DevOps Agent Space"
  type        = string
}


# Github vars
variable "github_org" {
  description = "GitHub organization or username"
  type        = string
}

variable "github_owner_type" {
  description = "GitHub owner type: 'organization' or 'user'"
  type        = string
  validation {
    condition     = contains(["organization", "user"], var.github_owner_type)
    error_message = "github_owner_type must be 'organization' or 'user'"
  }
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_repo_id" {
  description = "GitHub repository ID (numeric)"
  type        = string
}

variable "github_service_id" {
  description = "GitHub service ID from DevOps Agent RegisterService"
  type        = string
}

variable "devops_agent_webhook_url" {
  description = "DevOps Agent webhook URL for triggering investigations"
  type        = string
}

variable "devops_agent_webhook_secret" {
  description = "DevOps Agent webhook secret for HMAC authentication"
  type        = string
  sensitive   = true
}
