terraform {
    backend "s3" {
        bucket = "tfstate"
        key = "production/terraform.tfstate"
        region = "us-east-1"

        skip_credentials_validation = true
        skip_requesting_account_id = true
        skip_metadata_api_check = true
        
        insecure = true
        use_lockfile = true
        use_path_style = true
    }
}

module "kind_cluster" {
    source = "../modules/kind-cluster"

    name = "production-cluster"
    kubeconfig_path = "${path.module}/kubeconfig"

    control_plane_port_mappings = [
        {
            container_port = 80
            host_port = 8082
        },
        {
            container_port = 443
            host_port = 8445
        }
    ]

    worker_count = 2
}
