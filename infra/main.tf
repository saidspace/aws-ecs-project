# ---------- Call the VPC module ----------
module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  azs      = ["eu-west-2a", "eu-west-2b"]
}

# ---------- Call the ECR module ----------
module "ecr" {
  source          = "./modules/ecr"
  repository_name = "threat-composer"
}

# ---------- Call the ALB module ----------
module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

# ---------- Call the ECS module ----------
module "ecs" {
  source                = "./modules/ecs"
  image_url             = module.ecr.repository_url
  public_subnet_ids     = module.vpc.public_subnet_ids
  ecs_security_group_id = module.alb.ecs_security_group_id
  target_group_arn      = module.alb.target_group_arn
  listener_dependency   = module.alb.listener_arn
}