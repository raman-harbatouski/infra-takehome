resource "postgresql_database" "postgrest" {
  name       = "postgrest"
  depends_on = [docker_container.postgres]
}

resource "random_password" "superuser" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "postgresql_role" "superuser" {
  name       = "superuser"
  password   = random_password.superuser.result
  login      = true
  superuser  = true
  depends_on = [docker_container.postgres]
}
