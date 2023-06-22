# https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest/submodules/service
resource "aws_security_group" "security_group_s3_manager" {
  name        = "${var.username_prefix}_allow_8080"
  description = "allow 8080"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.username_prefix}_allow_tls"
  }
}

resource "aws_ecs_cluster" "ecs_s3_manager_cluster" {
  name = "${var.username_prefix}-ecs-terraform"

}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.username_prefix}-ecs-service-terraform"
  cluster         = aws_ecs_cluster.ecs_s3_manager_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_s3_manager.arn
  desired_count   = 1
  
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base = 0
  }

  network_configuration {
    subnets = ["subnet-089fc7faf593f71ef", "subnet-084925d72ec5d9cda", "subnet-013343c36fea19c5b"]
    security_groups = [aws_security_group.security_group_s3_manager.id]
    assign_public_ip = true
  }

depends_on = [
  aws_ecs_cluster.ecs_s3_manager_cluster,
  aws_ecs_task_definition.ecs_task_s3_manager,
  aws_security_group.security_group_s3_manager
  ]
}


resource "aws_ecs_task_definition" "ecs_task_s3_manager" {
  family = "${var.username_prefix}-ecs-terraform-s3-manager"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      name      = "s3-manager-tf"
      image     = "cloudlena/s3manager"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ],
      environment = [
          {
              name = "region",
              value = "eu-central-1"
          },
          {
              name = "ACCESS_KEY_ID",
              value = ""
          },
          {
              name = "SECRET_ACCESS_KEY",
              value = ""
          }
      ]
    }
  ])
  
  depends_on = [
    aws_ecs_cluster.ecs_s3_manager_cluster
  ]
}
