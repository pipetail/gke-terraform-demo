module "monitoring" {
  source              = "../modules/monitoring"
  project             = var.project
  name_prefix         = "${var.project_slug}-${var.environment_name_suffix}-${random_string.suffix.result}"
  notification_emails = var.notification_emails

  host = "app.${var.dns_zone_suffix}"
  path = "/"
}
