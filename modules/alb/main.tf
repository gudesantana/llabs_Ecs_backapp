resource "aws_alb_target_group" "default" {
  name                 = "tgt-alb-ecs-${var.project_name}-${var.environment}"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    path     = var.health_check_path
    protocol = "HTTP"
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_alb" "alb" {
  name            = "alb-ecs-${var.project_name}-${var.environment}"
  subnets         = var.public_subnet_ids
  security_groups = ["${aws_security_group.alb.id}"]

  tags = {
    Environment = var.environment
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.default.id
    type             = "forward"
  }
}

resource "aws_security_group" "alb" {
  name   = "sg_alb_ecs_${var.project_name}_${var.environment}"
  vpc_id = var.vpc_id

  tags = {
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "https_from_anywhere" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = var.allow_cidr_block
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "outbound_internet_access" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}
