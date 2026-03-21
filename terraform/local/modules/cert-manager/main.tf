terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
}

resource "helm_release" "this" {
  name             = var.name
  repository       = "oci://quay.io/jetstack/charts"
  chart            = "cert-manager"
  namespace        = var.namespace
  create_namespace = true
  version          = var.release_version
  wait             = var.wait
  timeout          = var.timeout
  skip_crds        = true

  values = concat(
    [for f in var.values_files : file(f)],
    length(keys(var.values)) > 0 ? [yamlencode(var.values)] : []
  )

  set = [
    {
      name  = "crds.enabled"
      value = tostring(var.install_crds)
    }
  ]

  lifecycle {
    ignore_changes = [version]
  }
}
