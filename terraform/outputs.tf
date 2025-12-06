output "postgres_container_id" {
  description = "PostgreSQL container ID"
  value       = docker_container.postgres.id
}

output "backend_container_id" {
  description = "Backend container ID"
  value       = docker_container.backend.id
}

output "frontend_container_id" {
  description = "Frontend container ID"
  value       = docker_container.frontend.id
}

output "postgres_port" {
  description = "PostgreSQL external port"
  value       = var.postgres_external_port
}

output "backend_url" {
  description = "Backend URL"
  value       = "http://localhost:${var.backend_external_port}"
}

output "frontend_url" {
  description = "Frontend URL"
  value       = "http://localhost:${var.frontend_port}"
}

output "network_name" {
  description = "Docker network name"
  value       = docker_network.clicker_network.name
}
