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
