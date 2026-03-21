variable "name" {
  description = "Helm release name"
  type        = string
  default     = "traefik"
}

variable "namespace" {
  description = "Namespace to install Traefik into"
  type        = string
  default     = "traefik"
}

variable "release_version" {
  description = "Helm chart version"
  type        = string
}

variable "values_files" {
  description = "Paths to YAML values files"
  type        = list(string)
  default     = []
}

variable "values" {
  description = "Inline values"
  type        = any
  default     = {}
}

variable "wait" {
  type    = bool
  default = true
}

variable "timeout" {
  type    = number
  default = 300
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
}
