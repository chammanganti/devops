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
                pools = [
                    {
                        servers = 1
                        name = "pool-0"
                        size = "2Gi"
                    }
                ]
            }
            extraResources = [
                <<-EOT
                apiVersion: v1
                kind: Service
                metadata:
                  name: minio-console-lb
                spec:
                  ports:
                  - name: https-console
                    port: 9443
                    protocol: TCP
                    targetPort: 9443
                  selector:
                    v1.min.io/tenant: minio
                  type: LoadBalancer
                EOT
                ,
                <<-EOT
                apiVersion: v1
                kind: Service
                metadata:
                  name: minio-hl-lb
                spec:
                  ports:
                  - name: https-minio
                    port: 9000
                    protocol: TCP
                    targetPort: 9000
                  selector:
                    v1.min.io/tenant: minio
                  type: LoadBalancer
                EOT
            ]
        })
    ]
}
