data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source          = "./modules/vpc"
  vpc_cidr        = "11.0.0.0/16"
  public_subnets  = ["11.0.1.0/24", "11.0.4.0/24"]
  private_subnets = ["11.0.2.0/24", "11.0.3.0/24"]
  azs             = data.aws_availability_zones.available.names
}

module "ecs-cluster" {
  source       = "./modules/ecs-cluster"
  cluster_name = "ecs-flask"
  logs_path    = "/ecs/logs"
  tags = {
    Name        = "ecs-flask-cluster"
    Environment = "dev"
  }
}

module "alb-security-group" {
  source      = "./modules/security-group"
  name        = "ecs-flask-sg"
  description = "Security group for ALB for ECS Flask service"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "ecs-security-group" {
  source      = "./modules/security-group"
  name        = "ecs-flask-service-sg"
  description = "Security group for ECS Flask service"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 4000
      to_port         = 4000
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.alb-security-group.id]
    }
  ]
}

module "alb" {
  source            = "./modules/load-balancer"
  alb_name          = "ecs-flask-alb"
  lb_type           = "http"
  vpc_id            = module.vpc.vpc_id
  subnet_groups     = module.vpc.public_subnet_ids
  security_groups   = module.alb-security-group.id
  container_port    = 4000
  health_check_path = "/api/healthcheck"
  tags = {
    Name        = "ecs-flask-alb"
    Environment = "dev"
  }
}

data "aws_ecr_repository" "expo-ecr" {
  name = "hms/frontend"
}

module "ecs-service" {
  source                  = "./modules/ecs-service"
  family_name             = "ecs-flask-task"
  app_name                = "flask"
  ecr_repository_name     = data.aws_ecr_repository.expo-ecr.name
  aws_region              = "ap-south-1"
  cluster_id              = module.ecs-cluster.cluster_id
  port                    = 4000
  cpu                     = "256"
  memory                  = "512"
  ecsTaskExecutionRolearn = module.ecs-cluster.ecs_taskexecution_role_arn
  launch_type             = "FARGATE"
  # Add environment variables as per your application needs
  environment_variables = [
    {
      name  = "FLASK_ENV"
      value = "development"
    }
  ]
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.ecs-security-group.id
  target_group_arn  = module.alb.target_group_arn
  tags = {
    Name        = "ecs-flask-service"
    Environment = "dev"
  }
}
