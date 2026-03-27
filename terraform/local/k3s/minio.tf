resource "helm_release" "minio" {
  name             = "minio"
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "minio"
  namespace        = local.minio_namespace
  create_namespace = true

  values = [
    yamlencode({
      image = {
        repository = "bitnamilegacy/minio"
      }
      auth = {
        rootUser     = var.minio_access_key
        rootPassword = var.minio_secret_key
      }
      mode = "standalone"
      persistence = {
        enabled = true
        size    = "2Gi"
      }
      service = {
        type = "NodePort"
        nodePorts = {
          api = "30900"
        }
      }
      console = {
        image = {
          repository = "bitnamilegacy/minio-object-browser"
        }
      }
    })
  ]
}

resource "kubectl_manifest" "minio_console_certificate" {
  yaml_body = <<-YAML
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: ${local.minio_console_tls_secret}
      namespace: ${local.minio_namespace}
    spec:
      secretName: ${local.minio_console_tls_secret}
      issuerRef:
        name: ${local.letsencrypt_issuer}
        kind: ClusterIssuer
      dnsNames:
        - ${var.minio_console_domain}
  YAML

  depends_on = [helm_release.minio]
}

resource "kubectl_manifest" "minio_console_headers" {
  yaml_body = <<-YAML
    apiVersion: traefik.io/v1alpha1
    kind: Middleware
    metadata:
      name: ${local.minio_console_headers_middleware}
      namespace: ${local.minio_namespace}
    spec:
      headers:
        customRequestHeaders:
          X-Forwarded-For: ""
          X-Forwarded-Proto: "https"
  YAML

  depends_on = [helm_release.minio]
}

resource "kubectl_manifest" "minio_console_redirect" {
  yaml_body = <<-YAML
    apiVersion: traefik.io/v1alpha1
    kind: Middleware
    metadata:
      name: ${local.minio_console_redirect_https_middleware}
      namespace: ${local.minio_namespace}
    spec:
      redirectScheme:
        scheme: https
        permanent: true
  YAML

  depends_on = [helm_release.minio]
}

resource "kubectl_manifest" "minio_console_ingress" {
  yaml_body = <<-YAML
    apiVersion: traefik.io/v1alpha1
    kind: IngressRoute
    metadata:
      name: minio-console
      namespace: ${local.minio_namespace}
    spec:
      entryPoints:
        - websecure
      routes:
        - match: Host(`${var.minio_console_domain}`)
          kind: Rule
          middlewares:
            - name: ${local.minio_console_headers_middleware}
          services:
            - name: minio-console
              port: 9090
              passHostHeader: true
      tls:
        secretName: ${local.minio_console_tls_secret}
  YAML

  depends_on = [
    kubectl_manifest.minio_console_certificate,
    kubectl_manifest.minio_console_headers,
  ]
}

resource "kubectl_manifest" "minio_console_ingress_http" {
  yaml_body = <<-YAML
    apiVersion: traefik.io/v1alpha1
    kind: IngressRoute
    metadata:
      name: minio-console-http
      namespace: ${local.minio_namespace}
    spec:
      entryPoints:
        - web
      routes:
        - match: Host(`${var.minio_console_domain}`)
          kind: Rule
          middlewares:
            - name: ${local.minio_console_redirect_https_middleware}
          services:
            - name: minio-console
              port: 9090
  YAML

  depends_on = [kubectl_manifest.minio_console_redirect]
}
