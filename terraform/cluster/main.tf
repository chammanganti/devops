terraform {
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
            version = "3.6.2"
        }
        kind = {
            source = "tehcyx/kind"
            version = "0.11.0"
        }
    }
}

provider "docker" {}
provider "kind" {}
