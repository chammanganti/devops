locals {
  s3_endpoint = get_env("S3_ENDPOINT")
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "tfstate"

    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = "ap-southeast-1"
    endpoint     = local.s3_endpoint
    encrypt      = false
    use_lockfile = true

    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    insecure                    = true
    use_path_style              = true
  }
}
