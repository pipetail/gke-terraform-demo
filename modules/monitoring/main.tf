resource "google_monitoring_uptime_check_config" "http" {
  display_name = "${var.name_prefix}-main-api"
  timeout      = "60s"
  period       = "60s"

  http_check {
    path         = var.path
    port         = "443"
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project
      host       = var.host
    }
  }
}

resource "google_monitoring_notification_channel" "email" {
  for_each     = toset(var.notification_emails)
  display_name = "email - ${each.value}"
  type         = "email"
  labels = {
    email_address = each.value
  }
}

resource "google_monitoring_alert_policy" "probers" {
  project = var.project

  display_name = "HostDown"
  combiner     = "OR"
  conditions {
    display_name = "Host is unreachable"
    condition_monitoring_query_language {
      duration = "300s"
      query    = <<-EOT
      fetch
      uptime_url :: monitoring.googleapis.com/uptime_check/check_passed
      | align next_older(1m)
      | every 1m
      | group_by [resource.host], [val: fraction_true(value.check_passed)]
      | condition val < 60 '%'
      EOT
      trigger {
        count = 1
      }
    }
  }

  notification_channels = concat(
    [for x in values(google_monitoring_notification_channel.email) : x.id],
  )
}

resource "google_monitoring_alert_policy" "backend_latency" {
  project = var.project

  display_name = "LatencyHighP50"
  combiner     = "OR"
  conditions {
    display_name = "Percentile 50 latency too high"
    condition_monitoring_query_language {
      duration = "300s"
      query    = <<-EOT
        fetch https_lb_rule
        | metric 'loadbalancing.googleapis.com/https/backend_latencies'
        | align delta(5m)
        | every 5m
        | group_by [],
            [value_backend_latencies_percentile:
               percentile(value.backend_latencies, 50)]
        | condition value_backend_latencies_percentile > 1000 'ms'
      EOT
      trigger {
        count = 1
      }
    }
  }

  notification_channels = concat(
    [for x in values(google_monitoring_notification_channel.email) : x.id],
  )
}
