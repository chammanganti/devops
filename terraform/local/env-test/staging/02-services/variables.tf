variable "cloudflare_api_token" {
    type = string
    sensitive = true
}

variable "traefik_dashboard_username" {
    type = string
    sensitive = true
}

variable "traefik_dashboard_password" {
    type = string
    sensitive = true
}

variable "traefik_dashboard_secret" {
    type = string
    sensitive = true
}
