output "cluster_name" {
  description = "Name of the k3d cluster"
  value       = var.k3d_cluster_name
}

output "postgres_host" {
  description = "PostgreSQL connection host"
  value       = docker_container.postgres.hostname
}

output "postgres_port" {
  description = "PostgreSQL connection port"
  value       = var.postgres_port
}

output "postgres_connection_string" {
  description = "PostgreSQL connection string for the admin user"
  value       = "postgresql://postgres:${var.postgres_password}@localhost:${var.postgres_port}/app"
  sensitive   = true
}

output "postgrest_superuser_connection_string" {
  description = "PostgreSQL connection string for the postgrest superuser"
  value       = "postgresql://postgrest_superuser:${random_password.postgrest_superuser.result}@localhost:${var.postgres_port}/postgrest"
  sensitive   = true
}

output "postgrest_namespace" {
  description = "Kubernetes namespace where PostgREST is deployed"
  value       = kubernetes_namespace.postgrest.metadata[0].name
}

output "postgrest_url" {
  description = "URL to access PostgREST in the browser"
  value       = "http://localhost:8080"
}
