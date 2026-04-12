resource "aws_iam_role" "devops_agent" {
  name = "DevOpsAgentRole-${var.agent_space_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "aidevops.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# Attach the managed policy for DevOps Agent
resource "aws_iam_role_policy_attachment" "devops_agent_policy" {
  role       = aws_iam_role.devops_agent.name
  policy_arn = "arn:aws:iam::aws:policy/AIDevOpsAgentAccessPolicy"
}

# IAM Role for Operator App
resource "aws_iam_role" "devops_operator" {
  name = "DevOpsAgentRole-Operator-${var.agent_space_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "aidevops.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# Attach the managed policy for Operator App
resource "aws_iam_role_policy_attachment" "devops_operator_policy" {
  role       = aws_iam_role.devops_operator.name
  policy_arn = "arn:aws:iam::aws:policy/AIDevOpsOperatorAppAccessPolicy"
}

# Additional permissions for Operator App (not included in managed policy)
resource "aws_iam_role_policy" "devops_operator_additional" {
  name = "DevOpsOperatorAdditionalPermissions"
  role = aws_iam_role.devops_operator.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "aidevops:*"
        ]
        Resource = "arn:aws:aidevops:*:${data.aws_caller_identity.current.account_id}:agentspace/*"
      }
    ]
  })
}

# Wait for IAM role propagation
resource "time_sleep" "wait_for_iam" {
  depends_on      = [aws_iam_role.devops_agent, aws_iam_role.devops_operator]
  create_duration = "30s"
}

# DevOps Agent Space
resource "awscc_devopsagent_agent_space" "main" {
  name        = var.agent_space_name
  description = var.agent_space_description

  # Configura l'agente per comunicare in italiano
  language = "it"

  operator_app = {
    iam = {
      operator_app_role_arn = aws_iam_role.devops_operator.arn
    }
  }

  depends_on = [time_sleep.wait_for_iam]
}

# AWS Account Association (for monitoring this account)
resource "awscc_devopsagent_association" "aws_monitor" {
  agent_space_id = awscc_devopsagent_agent_space.main.agent_space_id
  service_id     = "aws"

  configuration = {
    aws = {
      account_id         = data.aws_caller_identity.current.account_id
      account_type       = "monitor"
      assumable_role_arn = aws_iam_role.devops_agent.arn
    }
  }
}

# GitHub Repository Association
resource "awscc_devopsagent_association" "github" {
  agent_space_id = awscc_devopsagent_agent_space.main.agent_space_id
  service_id     = var.github_service_id

  configuration = {
    git_hub = {
      owner      = var.github_org
      owner_type = var.github_owner_type
      repo_id    = var.github_repo_id
      repo_name  = var.github_repo
    }
  }
}

# Note: Generic webhook for CloudWatch alarm integration must be created via console:
# 1. Go to DevOps Agent console -> Agent Space -> Capabilities -> Webhook
# 2. Click "Generate webhook" to create a generic webhook
# 3. Copy the webhook URL and secret to terraform variables:
#    - devops_agent_webhook_url
#    - devops_agent_webhook_secret
