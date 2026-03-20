resource "helm_release" "this" {
    name = var.name
    repository = "oci://quay.io/jetstack/charts"
    chart = "cert-manager"
    namespace = var.namespace
    create_namespace = true
    version = var.release_version

    values = concat(
        [for f in var.values_files : file(f)],
        length(keys(var.values)) > 0 ? [yamlencode(var.values)] : []
    )

    set = [
        {
            name = "crds.enabled"
            value = true
        }
    ]
}
