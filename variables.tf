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

variable "cluster_name" {
  type = string
}

variable "vpc_name" {
  type    = string
  default = "vpc-1"
}

variable "default_node_pool_name" {
  type    = string
  default = "default"
}

variable "node_pool_default_node_count" {
  type    = number
  default = "1"
}


variable "node_pool_image_type" {
  type    = string
  default = "COS"
}

variable "node_pool_machine_type" {
  type    = string
  default = "e2-micro"
}

variable "node_pool_app_machine_type" {
  type    = string
  default = "e2-micro"
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation (size must be /28) to use for the hosted master network. This range will be used for assigning internal IP addresses to the master or set of masters, as well as the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network."
  type        = string
  default     = "10.5.0.0/28"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.3.0.0/16"
}

variable "vpc_secondary_cidr_block" {
  description = "The IP address range of the VPC's secondary address range in CIDR notation. A prefix of /16 is recommended. Do not use a prefix higher than /27."
  type        = string
  default     = "10.4.0.0/16"
}

variable "public_services_secondary_cidr_block" {
  description = "The IP address range of the VPC's public services secondary address range in CIDR notation. A prefix of /16 is recommended. Do not use a prefix higher than /27. Note: this variable is optional and is used primarily for backwards compatibility, if not specified a range will be calculated using var.secondary_cidr_block, var.secondary_cidr_subnetwork_width_delta and var.secondary_cidr_subnetwork_spacing."
  type        = string
  default     = "10.6.0.0/16"
}

variable "node_pool_min_node_count" {
  type    = number
  default = "1"
}

variable "node_pool_max_node_count" {
  type    = number
  default = "5"
}

variable "vpc_cidr_subnetwork_width_delta" {
  description = "The difference between your network and subnetwork netmask; an /16 network and a /20 subnetwork would be 4."
  type        = number
  default     = 4
}

variable "enable_vertical_pod_autoscaling" {
  description = "Enable vertical pod autoscaling"
  type        = string
  default     = true
}

variable "services" {
  type        = list(string)
  description = "Names of the service accounts to create."
  default     = []
}

variable "service_port" {
  type    = number
  default = "30000"
}

variable "service_port_name" {
  type    = string
  default = "https"
}

variable "argo_port" {
  type = number
}

variable "argo_port_name" {
  type    = string
  default = "argo-dev"
}

variable "target_tags" {
  type    = string
  default = "gke-dev"
}

variable "lb_name" {
  type    = string
  default = "gke-https-lb"
}

variable "zones_count" {
  type    = number
  default = 3
}

variable "mysql_version" {
  description = "The engine version of the database, e.g. `MYSQL_5_6` or `MYSQL_5_7`. See https://cloud.google.com/sql/docs/features for supported versions."
  type        = string
  default     = "MYSQL_5_7"
}

variable "mysql_db_machine_type" {
  description = "The machine type to use, see https://cloud.google.com/sql/pricing for more details"
  type        = string
  default     = "db-f1-micro"
}

variable "databases" {
  type        = list(string)
  description = "Names of the databases to create."
  default     = []
}

variable "name_override" {
  description = "You may optionally override the name_prefix + random string by specifying an override"
  type        = string
  default     = null
}

terraform {
  required_version = ">= 0.14"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.55"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.55"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 1.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.3"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.5.3"
    }
  }
}
