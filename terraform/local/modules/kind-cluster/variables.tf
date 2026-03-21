variable "name" {
  description = "Name of the cluster"
  type        = string
}

variable "node_image" {
  description = "Kind node image"
  type        = string
  default     = "kindest/node:v1.32.0"
}

variable "kubeconfig_path" {
  description = "Path to write the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "control_plane_port_mappings" {
  description = "Port mappings to expose from the control plane node"
  type = list(object({
    container_port = number
    host_port      = number
    protocol       = optional(string, "TCP")
  }))
  default = []
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.worker_count >= 0
    error_message = "worker_count must be 0 or greater."
  }
}
