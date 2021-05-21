
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.0"

  project_id   = var.project
  network_name = "${var.project_slug}-${random_string.suffix.result}"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "public"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = var.region
    },
    {
      subnet_name           = "private"
      subnet_ip             = "10.10.11.0/24"
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
        ip_cidr_range = "10.4.0.0/16"
      },

      {
        range_name    = "kube-services"
        ip_cidr_range = "10.5.0.0/19"
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
