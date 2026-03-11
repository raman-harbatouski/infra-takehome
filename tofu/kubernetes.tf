resource "kubernetes_namespace" "postgrest" {
  metadata {
    name = "postgrest"
  }

  depends_on = [terraform_data.k3d_ready]
}

resource "kubernetes_secret" "postgrest_superuser" {
  metadata {
    name      = "postgrest-superuser"
    namespace = kubernetes_namespace.postgrest.metadata[0].name
  }

  data = {
    PGRST_DB_URI = "postgresql://${postgresql_role.postgrest_superuser.name}:${random_password.postgrest_superuser.result}@host.docker.internal:${var.postgres_port}/postgrest"
  }

  depends_on = [postgresql_role.postgrest_superuser]
}

resource "kubernetes_config_map" "postgrest" {
  metadata {
    name      = "postgrest-config"
    namespace = kubernetes_namespace.postgrest.metadata[0].name
  }

  data = {
    PGRST_DB_SCHEMA    = "public"
    PGRST_DB_ANON_ROLE = "postgrest_superuser"
  }

  depends_on = [kubernetes_namespace.postgrest]
}

resource "kubernetes_manifest" "postgrest_deployment" {
  manifest = yamldecode(file("${path.module}/../k8s/deployment.yaml"))

  depends_on = [
    kubernetes_secret.postgrest_superuser,
    kubernetes_config_map.postgrest,
  ]
}

resource "kubernetes_manifest" "postgrest_service" {
  manifest = yamldecode(file("${path.module}/../k8s/service.yaml"))

  depends_on = [kubernetes_namespace.postgrest]
}

resource "kubernetes_manifest" "postgrest_ingress" {
  manifest = yamldecode(file("${path.module}/../k8s/ingress.yaml"))

  depends_on = [kubernetes_manifest.postgrest_service]
}

resource "kubernetes_manifest" "init_db" {
  manifest = yamldecode(file("${path.module}/../k8s/init-job.yaml"))

  wait {
    condition {
      type   = "Complete"
      status = "True"
    }
  }

  timeouts {
    create = "2m"
  }

  depends_on = [kubernetes_manifest.postgrest_deployment]
}

resource "kubernetes_manifest" "seed_data" {
  manifest = yamldecode(file("${path.module}/../k8s/seed-job.yaml"))

  depends_on = [kubernetes_manifest.init_db]
}
