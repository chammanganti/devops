terraform {
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
            version = "3.6.2"
        }
        helm = {
            source = "hashicorp/helm"
            version = "3.1.1"
        }
        kind = {
            source = "tehcyx/kind"
            version = "0.11.0"
        }
    }
}

provider "docker" {}
provider "helm" {
    kubernetes = {
        config_path = local.k8s_config_path
    }
}
provider "kind" {}
