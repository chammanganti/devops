locals {
    network_name = "kind"
    registry_name = "kind-registry"
    registry_port = 5001

    k8s_config_path = pathexpand("~/.kube/kind")
}
