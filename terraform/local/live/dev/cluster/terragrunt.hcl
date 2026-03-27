locals {
  env_vars = find_in_parent_folders("env.hcl")
  env      = read_terragrunt_config(local.env_vars).locals
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules//kind-cluster"
}

inputs = {
  name            = local.env.cluster_name
  kubeconfig_path = local.env.kubeconfig_path
  worker_count    = local.env.worker_count

  control_plane_port_mappings = local.env.control_plane_port_mappings
}
