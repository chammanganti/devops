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

locals {
    network_name = "kind"
    registry_name = "kind-registry"
    registry_port = 5001

    k8s_config_path = pathexpand("~/.kube/kind")
}

resource "docker_network" "kind" {
  name = local.network_name
  driver = "bridge"
}

resource "docker_container" "registry" {
    name = local.registry_name
    image = "registry:2"
    restart = "always"

    ports {
        internal = 5000
        external = local.registry_port
    }

    networks_advanced {
        name = docker_network.kind.name
    }
}

resource "kind_cluster" "default" {
    depends_on = [docker_container.registry]

    name = "test-cluster"
    node_image = "kindest/node:v1.27.1"

    kubeconfig_path = local.k8s_config_path

    kind_config {
        kind = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"

        containerd_config_patches = [
            <<-TOML
            [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${local.registry_port}"]
                endpoint = ["http://${local.registry_name}:5000"]
            TOML
        ]

        node {
            role = "control-plane"

            extra_port_mappings {
                container_port = 80
                host_port = 8080
            }
            extra_port_mappings {
                container_port = 443
                host_port = 8443
            }
        }

        node {
            role = "worker"
        }
    }
}
