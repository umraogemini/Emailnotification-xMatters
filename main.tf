provider "google" {
  project = var.project_id
  region  = "europe-west2"
  zone    = "europe-west2-b"
}

# Log-based Metric
resource "google_logging_metric" "log_metric" {
  name        = "log_based_metric"
  description = "Tracks critical error logs for xMatters integration"

  filter = "severity >= ERROR" # Adjust as needed

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

# xMatters Webhook Notification Channel
resource "google_monitoring_notification_channel" "xmatters_webhook" {
  display_name = "xMatters Webhook"
  type         = "webhook_tokenauth"

  labels = {
    url = var.xmatters_webhook_url # Replace with your xMatters webhook URL
  }

  sensitive_labels {
    auth_token = var.xmatters_auth_token # Replace with a secure token variable
  }
}

# Alert Policy for Log-Based Metric
resource "google_monitoring_alert_policy" "log_metric_alert_policy" {
  display_name = "Log-Based Metric Alert Policy"
  combiner     = "OR"

  conditions {
    display_name = "Condition: Log Metric Threshold"

    condition_threshold {
      filter          = <<EOT
        metric.type = "logging.googleapis.com/user/${google_logging_metric.log_metric.name}"
      EOT
      comparison     = "COMPARISON_GT"
      threshold_value = 1  # Trigger if metric exceeds this value
      duration       = "60s"

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.xmatters_webhook.id]
}
