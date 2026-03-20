locals {
    k8s_config_path = "${path.module}/../00-cluster/kubeconfig"

    cert_manager_name = "cert-manager"
    cert_manager_namespace = "cert-manager"
    cert_manager_release_version = "v1.20.0"

    traefik_name = "traefik"
    traefik_namespace = "traefik"
    traefik_release_version = "v39.0.5"
}
