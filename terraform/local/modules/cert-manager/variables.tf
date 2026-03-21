variable "name" {
  description = "Helm release name"
  type        = string
  default     = "cert-manager"
}

variable "namespace" {
  description = "Namespace to install cert-manager into"
  type        = string
  default     = "cert-manager"
}

variable "release_version" {
  description = "Helm chart version for both cert-manager and its CRDs"
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

variable "install_crds" {
  description = "Whether to install CRDs via Helm"
  type        = bool
  default     = true
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
