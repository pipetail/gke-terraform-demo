terraform {
  backend "gcs" {
    bucket = "pipetail-gke-terraform-demo"
    prefix = "infra"
  }
}

data "google_project" "project" {
  project_id = var.project
}

# Use a random suffix to prevent overlap in resource names
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  cloudbuild_roles = [
    "roles/viewer",
    "roles/compute.admin",
    "roles/iam.serviceAccountUser"
  ]
}

resource "google_project_iam_member" "cloudbuild" {
  for_each = toset(local.cloudbuild_roles)

  project = var.project
  role    = each.value
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [
    google_project_service.services["cloudbuild.googleapis.com"],
  ]
}

# Cloud Resource Manager needs to be enabled first, before other services.
resource "google_project_service" "resourcemanager" {
  project            = var.project
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "services" {
  project = data.google_project.project.project_id
  for_each = toset([
    "compute.googleapis.com",
    "cloudkms.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iap.googleapis.com",
    "monitoring.googleapis.com",
    "servicenetworking.googleapis.com",
    "stackdriver.googleapis.com",
    "storage-api.googleapis.com",
    "vpcaccess.googleapis.com",
  ])
  service            = each.value
  disable_on_destroy = false

  depends_on = [
    google_project_service.resourcemanager,
  ]
}

provider "google" {
  project = var.project
  region  = var.region
}

provider "google-beta" {
  project = var.project
  region  = var.region
}
