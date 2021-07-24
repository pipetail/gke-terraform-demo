data "google_client_config" "default" {}

resource "google_container_cluster" "primary" {
  name             = "${var.project_slug}-${var.environment_name_suffix}-${random_string.suffix.result}"
  location         = var.region
  enable_autopilot = true

  network    = module.vpc.network_name
  subnetwork = module.vpc.subnets_names[0]

  ip_allocation_policy {
    cluster_secondary_range_name  = "kube-pods"
    services_secondary_range_name = "kube-services"
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.kubernetes_authorized_cidr_blocks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  depends_on = [
    google_project_service.services["compute.googleapis.com"],
    google_project_service.services["container.googleapis.com"],
  ]
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}

data "kubernetes_namespace" "kube_system" {
  metadata {
    name = "kube-system"
  }
  depends_on = [
    google_container_cluster.primary,
  ]
}
