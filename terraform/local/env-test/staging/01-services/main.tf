terraform {
    required_providers {
        helm = {
            source = "hashicorp/helm"
            version = "3.1.1"
        }
    }

    backend "s3" {
        bucket = "tfstate"
        key = "staging/01-services/terraform.tfstate"
        region = "us-east-1"

        skip_credentials_validation = true
        skip_requesting_account_id = true
        skip_metadata_api_check = true
        
        insecure = true
        use_lockfile = true
        use_path_style = true
    }
}

provider "helm" {
    kubernetes = {
        config_path = local.k8s_config_path
    }
}

module "cert_manager" {
    source = "../../modules/cert-manager"

    name = local.cert_manager_name
    namespace = local.cert_manager_namespace
    release_version = local.cert_manager_release_version
}

module "traefik" {
    source = "../../modules/traefik"

    name = local.traefik_name
    namespace = local.traefik_namespace
    release_version = local.traefik_release_version

    values_files = ["${path.module}/traefik.values.yaml"]
}
