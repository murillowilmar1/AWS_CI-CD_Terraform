variable "function_name" {
  type = string
}

variable "source_dir" {
  type        = string
  description = "Carpeta con el código fuente de la Lambda (ej: ../src)"
}

variable "handler" {
  type    = string
  default = "app.lambda_handler"
}

variable "runtime" {
  type    = string
  default = "python3.12"
}

variable "timeout" {
  type    = number
  default = 60
}

variable "memory_size" {
  type    = number
  default = 256
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "execution_role_arn" {
  type        = string
  description = "ARN del rol IAM que ejecuta la función (viene de platform/)"
}
