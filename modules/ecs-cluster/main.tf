#########################################
# This module creates an AWS ECS Cluster with a Task Execution Role and CloudWatch Logs configuration.
#########################################

variable "cluster_name" {
  description = "The name of the application"
  type        = string
}

variable "logs_path" {
  description = "The path for CloudWatch logs"
  type        = string
  default     = "/ecs/logs"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
#########################################
# Outputs
#########################################
output "cluster_id" {
  value = aws_ecs_cluster.aws-ecs-cluster.id
}

output "ecs_taskexecution_role_arn" {
  description = "ARN of the ECS Task Execution Role"
  value       = aws_iam_role.ecsTaskExecutionRole.arn
}

output "logs_path" {
  description = "Path for CloudWatch logs"
  value       = aws_cloudwatch_log_group.ecs_logs.name
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ######################################################
# # Resources
# ######################################################
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.cluster_name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = var.cluster_name
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = var.logs_path
  retention_in_days = 7
}
