locals {
  env = "dev"

  cluster_name    = "${local.env}-cluster"
  kubeconfig_path = "${get_terragrunt_dir()}/cluster/kubeconfig"
  worker_count    = 1
  control_plane_port_mappings = [
    { container_port = 80, host_port = 8080, protocol = "TCP" },
    { container_port = 443, host_port = 8443, protocol = "TCP" }
  ]

  cert_manager_name      = "cert-manager"
  cert_manager_namespace = "cert-manager"
  cert_manager_version   = "v1.20.0"

  traefik_name      = "traefik"
  traefik_namespace = "traefik"
  traefik_version   = "v39.0.5"
}
