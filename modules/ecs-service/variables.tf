variable "app_name" {}
variable "aws_region" {}
variable "ecr_repository_name" {}
variable "family_name" {}
variable "cluster_id" {}

variable "port" {
  default = 80
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "cpu" {
  default = "256"
  validation {
    error_message = "CPU must be a valid integer value."
    # Ensure the CPU is a valid integer
    condition = can(regex("^[0-9]+$", var.cpu))
  }
}

variable "memory" {
  default = "512"
  validation {
    error_message = "Memory must be a valid integer value."
    # Ensure the memory is a valid integer
    condition = can(regex("^[0-9]+$", var.memory))
  }
}

variable "ecsTaskExecutionRolearn" {}

variable "launch_type" {
  default = "FARGATE"
  validation {
    error_message = "launch_type must be either 'FARGATE' or 'EC2'."
    # Ensure the launch type is either FARGATE or EC2
    condition = contains(["FARGATE", "EC2"], var.launch_type)
  }
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "ecs_service_depends_on" {
  type    = list(string)
  default = []
}
