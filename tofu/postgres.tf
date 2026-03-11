resource "random_password" "postgrest_superuser" {
  length  = 24
  special = false
}

resource "terraform_data" "postgres_ready" {
  depends_on = [docker_container.postgres]

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<-EOT
      $attempts = 0
      $maxAttempts = 30
      do {
        $attempts++
        docker exec postgres-infra-takehome pg_isready -U postgres 2>$null
        if ($LASTEXITCODE -eq 0) { exit 0 }
        Write-Host "[$attempts/$maxAttempts] DB not accepting connections yet, retrying in 2s..."
        Start-Sleep -Seconds 2
      } while ($attempts -lt $maxAttempts)
      Write-Host "Timed out waiting for DB to accept connections"
      exit 1
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
