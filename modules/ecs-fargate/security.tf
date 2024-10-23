resource "aws_security_group" "lb" {
  name        = "sg_alb_ecs_app_${var.project_name}_${var.environment}"
  description = "controls access to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    protocol  = "tcp"
    from_port = var.app_port
    to_port   = var.app_port
    # cidr_blocks = ["0.0.0.0/0"]
    cidr_blocks = ["54.198.131.34/32"] # IP Frontapp 1a
  }

  ingress {
    protocol  = "tcp"
    from_port = var.app_port
    to_port   = var.app_port
    # cidr_blocks = ["0.0.0.0/0"]
    cidr_blocks = ["35.173.107.124/32"] # IP Frontapp 1c
  }

  ingress {
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = ["186.248.73.56/32"] # Meu IP
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "sg_task_ecs_app_${var.project_name}_${var.environment}"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}