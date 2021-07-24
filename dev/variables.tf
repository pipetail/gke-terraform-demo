# The default region for resources in the project, individual resources should
# have more specific variables defined to specify their region/location which
# increases the flexibility of deployments
variable "region" {
  type    = string
  default = "europe-west1"
}

variable "location" {
  description = "The location (region or zone) of the GKE cluster."
  type        = string
}

variable "zones" {
  type    = list(string)
  default = ["europe-west1-b", "europe-west1-c", "europe-west1-d"]
}

variable "project" {
  type = string
}

variable "project_slug" {
  type        = string
  description = "Identifier to be used for resource name prefixes"
}

variable "environment_name_prefix" {
  type = string
}

variable "environment_name_suffix" {
  type = string
}

variable "vpc_name" {
  type    = string
  default = "vpc-1"
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation (size must be /28) to use for the hosted master network. This range will be used for assigning internal IP addresses to the master or set of masters, as well as the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network."
  type        = string
  default     = "172.16.0.32/28"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.3.0.0/16"
}

variable "public_network_block" {
  type    = string
  default = "10.10.10.0/24"
}

variable "private_network_block" {
  type    = string
  default = "10.10.11.0/24"
}

variable "kubernetes_pods_block" {
  type    = string
  default = "10.4.0.0/16"
}

variable "kubernetes_services_block" {
  type    = string
  default = "10.5.0.0/19"
}

variable "kubernetes_authorized_cidr_blocks" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))

  default = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "public-all"
    }
  ]
}

variable "kubernetes_production_namespace" {
  type    = string
  default = "default"
}

variable "dns_zone_suffix" {
  type        = string
  description = "DNS zone suffix to append to all domains"
}

variable "vpc_secondary_cidr_block" {
  description = "The IP address range of the VPC's secondary address range in CIDR notation. A prefix of /16 is recommended. Do not use a prefix higher than /27."
  type        = string
  default     = "10.4.0.0/16"
}

variable "enable_lb_logging" {
  type        = bool
  default     = false
  description = "Whether to enable load balancer logging."
}

variable "notification_emails" {
  description = "Monitoring alerts notification email addresses"
  type        = list(string)
}

terraform {
  required_version = ">= 0.15"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.55"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.55"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.6.3"
    }
  }
}
