
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
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "This subnet has a description"
    }
  ]

  secondary_ranges = {
    private = [
      {
        range_name    = "kube-pods"
        ip_cidr_range = var.vpc_secondary_cidr_block
      },

      {
        range_name    = "kube-services"
        ip_cidr_range = var.public_services_secondary_cidr_block
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
