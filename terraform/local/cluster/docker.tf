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

resource "docker_volume" "dynamodb_data" {
    name = "dynamodb"
}

resource "docker_container" "dynamodb" {
    name = "dynamodb"
    image = "amazon/dynamodb-local:latest"
    restart = "always"

    command = [
        "-jar", "DynamoDBLocal.jar",
        "-sharedDb",
        "-dbPath", "."
    ]

    ports {
        internal = 8000
        external = 8000
    }

    mounts {
        target = "/home/dynamodblocal/data"
        source = docker_volume.dynamodb_data.name
        type = "volume"
    }

    working_dir = "/home/dynamodblocal"

    networks_advanced {
        name = docker_network.kind.name
    }
}
