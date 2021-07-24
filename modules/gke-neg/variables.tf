variable "project" {
  type = string
}

variable "name" {
  type = string
}

variable "kubernetes_service_name" {
  type = string
}

variable "kubernetes_pod_selector" {
  type = map(string)
}

variable "kubernetes_service_namespace" {
  type = string
}

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "zones" {
  type = list(string)
}
