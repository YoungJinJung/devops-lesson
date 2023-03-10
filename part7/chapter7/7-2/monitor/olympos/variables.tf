variable "assume_role_arn" {
  description = "The role to assume when accessing the AWS API."
  default     = ""
}

variable "atlantis_user" {
  description = "The username that will be triggering atlantis commands. This will be used to name the session when assuming a role. More information - https://github.com/runatlantis/atlantis#assume-role-session-names"
  default     = "atlantis_user"
}

variable "datadog_api_key" {
  description = "The Datadog API Key"
  default     = ""
}

variable "datadog_app_key" {
  description = "The Datadog APP Key"
  default     = ""
}
