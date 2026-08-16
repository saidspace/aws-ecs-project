# ---------- Security group for the ALB (public-facing) ----------

# Allows anyone on the internet to reach the load balancer on port 80
resource "aws_security_group" "alb" {
  name        = "ecs-project-alb-sg"
  description = "Allow HTTP inbound to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-project-alb-sg"
  }
}

# ---------- Security group for the ECS container ----------

# Allows 8080 ONLY from the ALB's security group, not the whole internet
resource "aws_security_group" "ecs" {
  name        = "ecs-project-ecs-sg"
  description = "Allow 8080 from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "App port from the ALB only"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-project-ecs-sg"
  }
}

# ---------- Application Load Balancer ----------
resource "aws_lb" "main" {
  name               = "ecs-project-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "ecs-project-alb"
  }
}

# ---------- Target group: where the ALB sends traffic ----------

# Health check hits "/" because Threat Composer has no /health route
resource "aws_lb_target_group" "main" {
  name        = "ecs-project-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
  }

  tags = {
    Name = "ecs-project-tg"
  }
}

# ---------- Listener: public traffic on 80 → forward to the target group ----------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}