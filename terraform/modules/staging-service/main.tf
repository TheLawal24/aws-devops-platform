resource "aws_cloudwatch_log_group" "staging" {
  name              = "/ecs/${var.project_name}-staging"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-staging-logs"
    Environment = "staging"
  }
}

resource "aws_ecs_task_definition" "staging" {
  family                   = "${var.project_name}-staging"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "APP_ENV"
          value = "staging"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.staging.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "app"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.project_name}-staging-task"
    Environment = "staging"
  }
}

resource "aws_lb_target_group" "staging" {
  name        = "${var.project_name}-staging-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.project_name}-staging-tg"
    Environment = "staging"
  }
}

resource "aws_lb_listener" "staging" {
  load_balancer_arn = var.load_balancer_arn
  port              = 8088
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging.arn
  }
}

resource "aws_ecs_service" "staging" {
  name            = "${var.project_name}-staging-service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.staging.arn

  desired_count = 1
  launch_type   = "FARGATE"

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.staging.arn
    container_name   = "app"
    container_port   = var.container_port
  }

  depends_on = [
    aws_lb_listener.staging
  ]

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

  tags = {
    Name        = "${var.project_name}-staging-service"
    Environment = "staging"
  }
}
