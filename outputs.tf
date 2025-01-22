output "log_metric_name" {
  value = google_logging_metric.log_metric.name
}

output "xmatters_notification_channel" {
  value = google_monitoring_notification_channel.xmatters_webhook.display_name
}
