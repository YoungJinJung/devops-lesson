provider "datadog" {
  validate = true
  api_key  = var.datadog_api_key
  app_key  = var.datadog_app_key
}

