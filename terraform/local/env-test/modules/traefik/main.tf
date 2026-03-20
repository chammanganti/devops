resource "helm_release" "this" {
    name = "traefik"
    repository = "https://traefik.github.io/charts"
    chart = "traefik"
    version = var.release_version
    namespace = "traefik"
    create_namespace = true

    values = concat(
        [for f in var.values_files : file(f)],
        length(keys(var.values)) > 0 ? [yamlencode(var.values)] : []
    )
}
