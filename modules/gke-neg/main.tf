# used only to extract cluster-uid
data "kubernetes_namespace" "kube_system" {
  metadata {
    name = "kube-system"
  }
}

resource "google_compute_network_endpoint_group" "main" {
  for_each = toset(var.zones)
  name     = var.name
  description = jsonencode({
    cluster-uid  = data.kubernetes_namespace.kube_system.metadata[0].uid
    namespace    = var.kubernetes_service_namespace
    service-name = var.kubernetes_service_name
    port         = "80"
  })
  network      = var.network
  subnetwork   = var.subnetwork
  default_port = "80"
  zone         = each.key

  lifecycle {
    ignore_changes = [
      size,
    ]
  }
}

resource "kubernetes_service" "main" {
  metadata {
    name      = var.kubernetes_service_name
    namespace = var.kubernetes_service_namespace
    annotations = {
      "cloud.google.com/neg" = jsonencode({
        exposed_ports = {
          "80" = {
            name = google_compute_network_endpoint_group.main[var.zones.0].name
          }
        }
      })
    }
  }
  spec {
    selector = var.kubernetes_pod_selector
    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["cloud.google.com/neg-status"]
    ]
  }

  depends_on = [
    google_compute_network_endpoint_group.main,
  ]
}
