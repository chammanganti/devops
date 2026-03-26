variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "cert_manager_version" {
  description = "cert-manager Helm chart version"
  type        = string
  default     = "v1.20.0"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "acme_email" {
  description = "Email address for ACME registration and cert notifications"
  type        = string
}

variable "acme_server" {
  description = "ACME server URL"
  type        = string
  default     = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

variable "minio_access_key" {
  description = "MinIO admin access key"
  type        = string
  sensitive   = true
}

variable "minio_secret_key" {
  description = "MinIO admin secret key"
  type        = string
  sensitive   = true
}

variable "minio_pools" {
  description = "MinIO storage pools"
  type = list(object({
    name    = string
    servers = number
    size    = string
  }))
  default = [
    {
      name    = "pool-0"
      servers = 1
      size    = "2Gi"
    }
  ]
}

variable "minio_console_domain" {
  description = "MinIO console UI domain"
  type        = string
}

variable "minio_api_domain" {
  description = "MinIO S3 API endpoint domain"
  type        = string
}
