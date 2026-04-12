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

variable "agent_space_name" {
  description = "Name of the DevOps Agent Space"
  type        = string
}

variable "agent_space_description" {
  description = "Description of the DevOps Agent Space"
  type        = string
  default     = "DevOps Agent Space for EKS microservice monitoring"
}


# Github vars
variable "github_org" {
  description = "GitHub organization or username"
  type        = string
}

variable "github_owner_type" {
  description = "GitHub owner type: 'organization' or 'user'"
  type        = string
  default     = "organization"
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
