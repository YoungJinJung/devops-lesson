variable "monitor_name" {
  type        = string
  description = "Name of monitor in Datadog U.I"
}

variable "monitor_type" {
  type        = string
  description = "Type of monitor."
}

variable "notify" {
  type        = string
  description = "For notification, ex) e-mail, slack"
  default     = ""
}

variable "query" {
  type        = string
  description = "Query for monitor."
}

variable "message" {
  type        = string
  description = "Alert message for notification."
}

variable "thresholds" {
  type        = map(any)
  description = "map of thresholds."
  default     = {}
}

variable "escalation_message" {
  type        = string
  description = "Alert message for re-notification."
}

variable "evaluation_delay" {
  type        = string
  description = "evaluation delay"
  default     = 15
}

variable "datadog_monitor_tags" {
  description = "Configurable labels that can be applied to monitor"
  type        = list(any)
}

variable "datadog_monitor_module_tags" {
  description = "Configurable labels that can be applied to monitor"
  type        = list(any)
  default     = ["common_system"]
}

variable "new_host_delay" {
  description = "Seconds for new host delay."
  default     = 360
}

variable "new_group_delay" {
  description = "Seconds for new group delay."
  default     = 360
}

variable "notify_no_data" {
  description = "Notify no data"
  default     = false
}

variable "renotify_interval" {
  description = "renotify interval, minute"
  default     = 60
}

variable "require_full_window" {
  description = "require_full_window"
  default     = true
}
