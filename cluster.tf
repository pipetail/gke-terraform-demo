data "google_container_engine_versions" "main" {
  provider = google-beta
  location = var.location
}

data "google_compute_zones" "available" {
}

# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source     = "terraform-google-modules/kubernetes-engine/google"
  project_id = var.project
  name       = "${var.project_slug}-${random_string.suffix.result}"

  region = var.region
  zones  = data.google_compute_zones.available.names

  network           = module.vpc.network_name
  subnetwork        = module.vpc.subnets_names[0]
  ip_range_pods     = "kube-pods"
  ip_range_services = "kube-services"

  # workload identity
  identity_namespace = "enabled"

  master_authorized_networks = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "all-for-testing"
    },
  ]

  http_load_balancing        = true
  horizontal_pod_autoscaling = true
  network_policy             = true

  # The kubernetes masters version
  kubernetes_version = data.google_container_engine_versions.main.release_channel_default_version["REGULAR"]

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "e2-medium"
      node_locations     = "${var.region}-a,${var.region}-b"
      min_count          = 1
      max_count          = 3
      local_ssd_count    = 0
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = false
      initial_node_count = 2
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_write"
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}
  }

  node_pools_taints = {
    all = []
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "http-ingress",
    ]
  }

  depends_on = [
    google_project_service.services["compute.googleapis.com"],
    google_project_service.services["container.googleapis.com"],
  ]

}

output "get-credentials" {
  value = "gcloud container clusters get-credentials ${module.gke.name} --region ${var.region} --project ${var.project}"
}
