
# output "ip_address" {
#   value = data.aws_vpc.default
# }


output "task_definition_ip_address" {
  value = data.aws_ecs_service.service_s3_manager.task_definition
}
