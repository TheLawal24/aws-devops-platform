output "staging_service_name" {
  value = module.staging.service_name
}

output "staging_url" {
  value = "http://${module.ecs.load_balancer_dns_name}:8088"
}
