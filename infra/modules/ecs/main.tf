# ---------- IAM execution role: lets ECS pull the image and write logs ----------
resource "aws_iam_role" "execution" {
  name = "ecs-project-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

# Attach AWS's standard ECS execution policy (ECR pull + CloudWatch logs)
resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ---------- ECS cluster ----------
resource "aws_ecs_cluster" "main" {
  name = "ecs-project-cluster"
}

# ---------- Task definition ----------
resource "aws_ecs_task_definition" "main" {
  family                   = "threat-composer-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.execution.arn

  container_definitions = jsonencode([{
    name      = "threat-composer"
    image     = "${var.image_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 8080
      protocol      = "tcp"
    }]
  }])
}

# ---------- ECS service ----------
resource "aws_ecs_service" "main" {
  name            = "threat-composer-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "threat-composer"
    container_port   = 8080
  }

  depends_on = [var.listener_dependency]
}