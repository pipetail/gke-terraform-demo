data "google_dns_managed_zone" "main" {
  name = "pipetail-cloud"
}

resource "google_dns_record_set" "app" {
  name         = "app.${data.google_dns_managed_zone.main.dns_name}"
  managed_zone = data.google_dns_managed_zone.main.name
  type         = "A"
  ttl          = 300

  rrdatas = [module.https_lb.global_address]
}

module "https_lb" {
  source = "../modules/https_lb"

  project     = var.project
  name_prefix = "${var.project_slug}-${var.environment_name_suffix}-${random_string.suffix.result}"
  url_map     = google_compute_url_map.main.self_link

  https_redirect = true

  domains = [
    google_dns_record_set.app.name,
  ]
}


resource "google_compute_url_map" "main" {
  name            = "${var.project_slug}-${var.environment_name_suffix}-${random_string.suffix.result}"
  default_service = google_compute_backend_service.app.self_link

  host_rule {
    hosts        = ["app.${trimsuffix(data.google_dns_managed_zone.main.dns_name, ".")}"]
    path_matcher = "app"
  }

  path_matcher {
    name            = "app"
    default_service = google_compute_backend_service.app.self_link

  }
}
