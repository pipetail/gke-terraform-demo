resource "google_compute_health_check" "app" {
  name               = "${var.project_slug}-${var.environment_name_suffix}-${random_string.suffix.result}-main-api"
  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_backend_service" "app" {
  name = "${var.project_slug}-${var.environment_name_suffix}-${random_string.suffix.result}-main-api"

  health_checks = [
    google_compute_health_check.app.id,
  ]

  dynamic "backend" {
    for_each = module.neg_app.neg_id
    content {
      group          = backend.value
      balancing_mode = "RATE"
      max_rate       = 1000
    }
  }
}

module "neg_app" {
  source = "../modules/gke-neg"

  name = "${var.project_slug}-${var.environment_name_suffix}-${random_string.suffix.result}-nginx"
  kubernetes_pod_selector = {
    app = "nginx"
  }
  kubernetes_service_namespace = "default"
  kubernetes_service_name      = "nginx"
  project                      = var.project
  network                      = module.vpc.network_name
  subnetwork                   = module.vpc.subnets_names[0]

  zones = var.zones

  depends_on = [
    google_container_cluster.primary,
  ]
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          image = "nginx:1.7.8"
          name  = "nginx"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}
