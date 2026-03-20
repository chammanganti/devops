terraform {
    required_providers {
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "3.0.1"
        }
    }

    backend "s3" {
        bucket = "tfstate"
        key = "staging/02-services/terraform.tfstate"
        region = "us-east-1"

        skip_credentials_validation = true
        skip_requesting_account_id = true
        skip_metadata_api_check = true
        
        insecure = true
        use_lockfile = true
        use_path_style = true
    }
}

provider "kubernetes" {
  config_path = local.k8s_config_path
}

resource "kubernetes_secret_v1" "cloudflare_api_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = local.cert_manager_namespace
  }

  data = {
    token = var.cloudflare_api_token
  }

  type = "Opaque"
}

resource "kubernetes_manifest" "letsencrypt" {
    manifest = {
        apiVersion = "cert-manager.io/v1"
        kind = "ClusterIssuer"

        metadata = {
            name = "letsencrypt"
        }

        spec = {
            acme = {
                email = "chammanganti@gmail.com"
                server = "https://acme-staging-v02.api.letsencrypt.org/directory"
                privateKeySecretRef = {
                    name = "letsencrypt-dns-account-key"
                }
                solvers = [
                    {
                        dns01 = {
                            cloudflare = {
                                email = "chammanganti@gmail.com"
                                apiTokenSecretRef = {
                                    name: "cloudflare-api-token"
                                    key: "token"
                                }
                            }
                        }
                    }
                ]
            }
        }
    }
}

resource "kubernetes_secret_v1" "traefik_dashboard_auth_secret" {
  metadata {
    name      = "dashboard-auth-secret"
    namespace = local.traefik_namespace
  }

  data = {
    username = var.traefik_dashboard_username
    password = var.traefik_dashboard_password
  }

  type = "kubernetes.io/basic-auth"
}

resource "kubernetes_manifest" "traefik_dashboard_auth" {
    manifest = {
        apiVersion = "traefik.io/v1alpha1"
        kind = "Middleware"
        metadata = {
            name = "dashboard-auth"
            namespace = local.traefik_namespace
        }
        spec = {
            basicAuth = {
                secret = var.traefik_dashboard_secret
            }
        }
    }
}

resource "kubernetes_manifest" "traefik_dashboard_tls" {
    depends_on = [kubernetes_manifest.letsencrypt]

    manifest = {
        apiVersion = "cert-manager.io/v1"
        kind = "Certificate"
        metadata = {
            name = "dashboard-tls"
            namespace = local.traefik_namespace
        }
        spec = {
            secretName = "dashboard-tls"
            dnsNames = [
                "traefik-stg-local.chammanganti.dev"
            ]
            issuerRef = {
                name = "letsencrypt"
                kind = "ClusterIssuer"
            }
        }
    }
}
