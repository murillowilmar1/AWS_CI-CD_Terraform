variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "repo_connection_arn" {
  type = string
}

variable "repo_full_name" {
  type = string
}

variable "artifact_bucket" {
  type = string
}

# Variables que no usa esta capa pero comparten el mismo .tfvars
variable "project_name" {
  type    = string
  default = ""
}
variable "platform_state_bucket" {
  type    = string
  default = ""
}
variable "platform_state_region" {
  type    = string
  default = ""
}


variable "branch" {
  type = string
}