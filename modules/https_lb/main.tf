resource "google_compute_global_address" "main" {
  name = var.name_prefix
}

resource "google_compute_managed_ssl_certificate" "main" {
  count    = var.use_own_certificate ? 0 : 1
  provider = google-beta
  name     = var.name_prefix
  managed {
    domains = var.domains
  }
}

resource "google_compute_target_http_proxy" "main" {
  name    = "${var.name_prefix}-http"
  url_map = var.https_redirect == false ? var.url_map : join("", google_compute_url_map.https_redirect.*.self_link)
}

resource "google_compute_global_forwarding_rule" "http" {
  provider   = google-beta
  name       = "${var.name_prefix}-http"
  target     = google_compute_target_http_proxy.main.self_link
  ip_address = google_compute_global_address.main.address
  port_range = "80"

  depends_on = [google_compute_global_address.main]
}

resource "google_compute_ssl_policy" "main" {
  name            = var.name_prefix
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

resource "google_compute_global_forwarding_rule" "https" {
  provider   = google-beta
  name       = "${var.name_prefix}-https"
  target     = google_compute_target_https_proxy.main.self_link
  ip_address = google_compute_global_address.main.address
  port_range = "443"
  depends_on = [google_compute_global_address.main]
}

resource "google_compute_target_https_proxy" "main" {
  project = var.project
  name    = "${var.name_prefix}-https"
  url_map = var.url_map

  ssl_policy = google_compute_ssl_policy.main.id

  ssl_certificates = compact(concat(var.own_certificates, google_compute_managed_ssl_certificate.main.*.self_link, ), )
}

resource "google_compute_url_map" "https_redirect" {
  count = var.https_redirect ? 1 : 0
  name  = "${var.name_prefix}-https-redirect"
  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}
