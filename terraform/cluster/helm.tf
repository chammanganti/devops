resource "helm_release" "minio_operator" {
    depends_on = [kind_cluster.default]

    name = "minio-operator"
    repository = "https://operator.min.io/"
    chart = "operator"
    namespace = "minio-operator"
    create_namespace = true
}

resource "helm_release" "minio" {
    depends_on = [helm_release.minio_operator]

    name = "minio"
    repository = "https://operator.min.io/"
    chart ="tenant"
    namespace = "minio"
    create_namespace = true

    values = [
        yamlencode({
            tenant = {
                name = "minio"
                configSecret = {
                    accessKey = var.minio_access_key
                    secretKey = var.minio_secret_key
                }
            }
        })
    ]
}
