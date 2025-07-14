######################################################
# This module creates an AWS ECS Task Definition and ECS Service
######################################################
# aws ecr repository data source
data "aws_ecr_repository" "aws-ecr" {
  name = var.ecr_repository_name
}

# ######################################################
# # Resources
# ######################################################
# aws ecs task definition
resource "aws_ecs_task_definition" "ecs-task-def" {
  family                   = var.family_name
  requires_compatibilities = [var.launch_type]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.ecsTaskExecutionRolearn

  container_definitions = jsonencode([
    {
      name  = var.app_name
      image = "${data.aws_ecr_repository.aws-ecr.repository_url}"
      portMappings = [
        {
          containerPort = var.port
          hostPort      = var.port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.app_name}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = [var.environment_variables]
    }
  ])

  tags = var.tags
}

# aws ecs service
resource "aws_ecs_service" "ecs-service" {
  name            = var.app_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.ecs-task-def.arn
  desired_count   = 1
  launch_type     = var.launch_type

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.app_name
    container_port   = var.port
  }

  depends_on = var.ecs_service_depends_on

  tags = var.tags
}
