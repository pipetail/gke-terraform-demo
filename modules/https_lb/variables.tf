variable "project" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "own_certificates" {
  type        = list(string)
  description = "Bring your own certificate (self_link) instead of creating a managed one"
  default     = []
}

variable "use_own_certificate" {
  type    = bool
  default = false
}

variable "url_map" {
  type        = string
  description = "url_map self_link to be linked with http proxies"
}

variable "https_redirect" {
  description = "Set to `true` to enable https redirect on the lb."
  type        = bool
  default     = false
}

variable "domains" {
  type        = list(any)
  description = "domains to be associated with the TLS certificate"
  default     = []
}
