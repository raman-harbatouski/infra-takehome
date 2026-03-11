resource "random_password" "postgrest_superuser" {
  length  = 24
  special = false
}

resource "terraform_data" "postgres_ready" {
  depends_on = [docker_container.postgres]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      attempts=0
      max_attempts=30
      until docker exec postgres-infra-takehome pg_isready -U postgres 2>/dev/null; do
        attempts=$((attempts + 1))
        if [ "$attempts" -ge "$max_attempts" ]; then
          echo "Timed out waiting for DB to accept connections"
          exit 1
        fi
        echo "[$attempts/$max_attempts] DB not accepting connections yet, retrying in 2s..."
        sleep 2
      done
    EOT
  }
}

resource "postgresql_database" "postgrest" {
  name       = "postgrest"
  depends_on = [terraform_data.postgres_ready]
}

resource "postgresql_role" "postgrest_superuser" {
  name       = "postgrest_superuser"
  password   = random_password.postgrest_superuser.result
  login      = true
  superuser  = true
  depends_on = [postgresql_database.postgrest]
}
