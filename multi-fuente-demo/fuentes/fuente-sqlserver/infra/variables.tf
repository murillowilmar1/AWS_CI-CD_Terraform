variable "environment" {
  type = string
}
variable "region" {
  type = string
}
variable "platform_state_bucket" {
  type = string
}
variable "platform_state_region" {
  type = string
}

variable "repo_connection_arn" {
  type    = string
  default = ""
}
variable "repo_full_name" {
  type    = string
  default = ""
}
variable "artifact_bucket" {
  type    = string
  default = ""
}
