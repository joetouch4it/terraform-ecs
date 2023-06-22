data "aws_vpc" "default" {
}

data "aws_ecs_service" "service_s3_manager" {
  service_name = aws_ecs_service.ecs_service.name
  cluster_arn      = aws_ecs_cluster.ecs_s3_manager_cluster.arn
}
