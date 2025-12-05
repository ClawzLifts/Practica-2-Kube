resource "kubernetes_deployment" "mariadb" {
  metadata {
    name = "mariadb"
    labels = {
      app = "mariadb"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "mariadb"
      }
    }
    template {
      metadata {
        labels = {
          app = "mariadb"
        }
      }
      spec {
        container {
          name  = "mariadb"
          image = "bitnami/mariadb:latest"
          port {
            container_port = 3306
          }
          env {
            name  = "MARIADB_USER"
            value = var.mariadb_user
          }
          env {
            name  = "MARIADB_PASSWORD"
            value = var.mariadb_password
          }
          env {
            name  = "MARIADB_DATABASE"
            value = var.mariadb_database
          }
          env {
            name  = "MARIADB_ROOT_PASSWORD"
            value = var.mariadb_password
          }
          volume_mount {
            name       = "mariadb-storage"
            mount_path = "/bitnami/mariadb"
          }
        }
        volume {
          name = "mariadb-storage"
          persistent_volume_claim {
            claim_name = "mariadb-pvc"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mariadb" {
  metadata {
    name = "mariadb-service"
    labels = {
      app = "mariadb"
    }
  }
  spec {
    selector = {
      app = "mariadb"
    }
    type = "ClusterIP"
    port {
      name        = "mariadb"
      port        = 3306
      target_port = 3306
    }
  }
}
