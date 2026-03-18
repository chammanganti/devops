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
