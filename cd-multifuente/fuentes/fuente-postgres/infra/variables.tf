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

# Variables que no usa esta capa pero que comparten el mismo .tfvars
# que los demás módulos (Terraform solo emite un warning, no un error).
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
