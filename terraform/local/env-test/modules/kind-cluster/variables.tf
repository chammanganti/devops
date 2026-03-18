variable "name" {
    type = string
    description = "Cluster name"
}

variable "node_image" {
    type = string
    description = "Kind node image"
    default = "kindest/node:v1.27.1"
}

variable "kubeconfig_path" {
    type = string
    description = "Kubeconfig path"
}

variable "control_plane_port_mappings" {
    type = list(object({
        container_port = number
        host_port = number
    }))
    default = [
        {
            container_port = 80
            host_port = 8080
        },
        {
            container_port = 443
            host_port = 8443
        }
    ]
}

variable "worker_count" {
    type = number
    default = 1
}
