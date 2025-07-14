#########################################
# This module creates an AWS Application Load Balancer (ALB) with optional HTTPS support, Target Group and Listener.
#########################################

variable "alb_name" {}
variable "container_port" {
  default = 80
}
variable "subnet_groups" {}
variable "security_groups" {}
variable "vpc_id" {}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listeners"
  type        = string
  default     = ""
}
variable "health_check_path" {
  default = "/"
}
variable "lb_type" {
  description = "Load Balancer type: http or https"
  type        = string
  default     = "http"
  validation {
    condition     = contains(["http", "https"], var.lb_type)
    error_message = "lb_type must be either 'http' or 'https'."
  }
}
variable "tags" {}

#########################################
# Outputs
#########################################
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.alb.zone_id
}

output "target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}

# ######################################################
# # Resources
# ######################################################
resource "aws_lb" "alb" {
  name                             = var.alb_name
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [var.security_groups]
  subnets                          = var.subnet_groups
  enable_deletion_protection       = false
  enable_http2                     = true
  enable_cross_zone_load_balancing = true
  tags                             = var.tags
}

resource "aws_lb_target_group" "app_tg" {
  name        = "${var.alb_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = var.tags
}

resource "aws_lb_listener" "http" {
  count             = var.lb_type == "http" ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_listener" "https_redirect" {
  count             = var.lb_type == "https" ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "redirect"

    redirect {
      port        = "80"
      protocol    = "HTTP"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_forward" {
  count             = var.lb_type == "https" ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
