// ----------------------------
// ecs.tf
// ----------------------------

# ----------------------------
# Variable for dynamic image tag
# ----------------------------
variable "image_tag" {
  type    = string
  default = "latest"
}

# ----------------------------
# ECS Security Group
# ----------------------------
resource "aws_security_group" "ecs_service" {
  name        = "ecs-service-sg"
  description = "Allow inbound traffic to ECS service"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 1337
    to_port     = 1337
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
    Name = "ecs-service-sg"
  }
}

# ----------------------------
# ECS Cluster
# ----------------------------
resource "aws_ecs_cluster" "strapi" {
  name = "strapi-cluster"
}

# ----------------------------
# ECS Task Definition
# ----------------------------
resource "aws_ecs_task_definition" "strapi" {
  family                   = "strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "strapi"
    image     = "shunnualisha8980/strapi-app:${var.image_tag}"
    essential = true
    portMappings = [
      {
        containerPort = 1337
        hostPort      = 1337
      }
    ]
  }])
}

# ----------------------------
# ECS Service with CodeDeploy + Load Balancer
# ----------------------------
resource "aws_ecs_service" "strapi" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.strapi.id
  task_definition = aws_ecs_task_definition.strapi.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets         = module.vpc.public_subnets
    security_groups = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = "strapi"
    container_port   = 1337
  }
}

# ----------------------------
# S3 Upload for AppSpec File
# ----------------------------
resource "aws_s3_object" "appspec" {
  bucket = "strapi786"
  key    = "deploy-strapi.zip"
  source = "${path.module}/../zipped/deploy-strapi.zip"
  etag   = filemd5("${path.module}/../zipped/deploy-strapi.zip")
}

