resource "datadog_monitor" "default" {
  name = var.monitor_name
  type = var.monitor_type

  message = var.message

  escalation_message = var.escalation_message

  query = var.query

  monitor_thresholds {
    warning           = lookup(var.thresholds, "warning", null)
    warning_recovery  = lookup(var.thresholds, "warning_recovery", null)
    critical          = lookup(var.thresholds, "critical", null)
    critical_recovery = lookup(var.thresholds, "critical_recovery", null)
    ok                = lookup(var.thresholds, "ok", null)
  }

  evaluation_delay    = var.evaluation_delay
  require_full_window = var.require_full_window
  renotify_interval   = var.renotify_interval
  new_host_delay      = var.new_host_delay
  notify_no_data      = var.notify_no_data
  locked              = "false"
  tags                = var.datadog_monitor_tags
}
