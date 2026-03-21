locals {
  env_vars = find_in_parent_folders("env.hcl")
  env      = read_terragrunt_config(local.env_vars).locals
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "cluster" {
  config_path = "../cluster"

  mock_outputs = {
    kubeconfig_path = "/tmp/mock-kubeconfig"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate"]
}

terraform {
  source = "../../../../modules//cert-manager"
}

inputs = {
  name            = local.env.cert_manager_name
  namespace       = local.env.cert_manager_namespace
  release_version = local.env.cert_manager_version
  kubeconfig_path = dependency.cluster.outputs.kubeconfig_path
}
