terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.1.6"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
}
provider "kubernetes" {
  config_path = var.kubeconfig_path
}
provider "kubectl" {
  config_path = var.kubeconfig_path
}

resource "kubectl_manifest" "traefik_config" {
  yaml_body = <<YAML
    apiVersion: helm.cattle.io/v1
    kind: HelmChartConfig
    metadata:
      name: traefik
      namespace: kube-system
    spec:
      valuesContent: |-
        api:
          dashboard: true
          insecure: true
        ports:
          traefik:
            expose:
              default: true
        additionalArguments:
          - "--entrypoints.websecure.forwardedHeaders.trustedIPs=127.0.0.1/32,10.42.0.0/16,192.168.0.0/16"
  YAML
}

module "cert_manager" {
  source = "../modules/cert-manager"

  kubeconfig_path = var.kubeconfig_path
  release_version = var.cert_manager_version
  install_crds    = true
  wait            = true
}

resource "kubernetes_secret_v1" "cloudflare_api_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = module.cert_manager.namespace
  }

  data = {
    token = var.cloudflare_api_token
  }

  type = "Opaque"

  depends_on = [module.cert_manager]
}

resource "kubectl_manifest" "letsencrypt" {
  yaml_body = <<-YAML
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: letsencrypt
    spec:
      acme:
        email: ${var.acme_email}
        server: ${var.acme_server}
        privateKeySecretRef:
          name: letsencrypt-dns-account-key
        solvers:
          - dns01:
              cloudflare:
                email: ${var.acme_email}
                apiTokenSecretRef:
                  name: cloudflare-api-token
                  key: token
  YAML

  depends_on = [module.cert_manager]
}
