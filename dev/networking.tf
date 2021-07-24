module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.0"

  project_id   = var.project
  network_name = "${var.project_slug}-${random_string.suffix.result}"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "public"
      subnet_ip     = var.public_network_block
      subnet_region = var.region
    },
    {
      subnet_name           = "private"
      subnet_ip             = var.private_network_block
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "private subnet for gke nodes"
    }
  ]

  secondary_ranges = {
    private = [
      {
        range_name    = "kube-pods"
        ip_cidr_range = var.kubernetes_pods_block
      },

      {
        range_name    = "kube-services"
        ip_cidr_range = var.kubernetes_services_block
      },
    ]
  }

  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    },
  ]

  depends_on = [
    google_project_service.services["compute.googleapis.com"],
  ]
}


resource "google_compute_firewall" "gke_allow_lb_all" {
  name        = "${var.project_slug}-${var.environment_name_suffix}-${random_string.suffix.result}-lb-allow-all"
  description = "allow HTTP traffic from HTTPS load balancer CIDRs"
  network     = module.vpc.network_name

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
  ]

}

resource "google_compute_router" "vpc_router" {
  name    = "${var.project_slug}-${random_string.suffix.result}"
  region  = var.region
  network = module.vpc.network_name

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "vpc_nat" {
  name    = "${var.project_slug}-${random_string.suffix.result}"
  project = var.project
  region  = var.region
  router  = google_compute_router.vpc_router.name

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = module.vpc.subnets_names[0]
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
