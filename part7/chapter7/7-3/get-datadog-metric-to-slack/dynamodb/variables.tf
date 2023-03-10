# Atlantis
variable "assume_role_arn" {
  description = "The role to assume when accessing the AWS API."
  default     = ""
}

variable "atlantis_user" {
  description = "The username that will be triggering atlantis commands. This will be used to name the session when assuming a role. More information - https://github.com/runatlantis/atlantis#assume-role-session-names"
  default     = "atlantis_user"
}

variable "remote_state_region" {
  default = "us-east-1"
}

variable "remote_state_bucket" {
  default = ""
}

variable "remote_state_key_map" {
  type = map(string)

  default = {
    "vpc" = ""
  }
}
