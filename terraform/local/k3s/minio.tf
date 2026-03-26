resource "helm_release" "minio_operator" {
  name             = "minio-operator"
  repository       = "https://operator.min.io/"
  chart            = "operator"
  namespace        = "minio-operator"
  create_namespace = true
}

resource "helm_release" "minio" {
  name             = "minio"
  repository       = "https://operator.min.io/"
  chart            = "tenant"
  namespace        = local.minio_namespace
  create_namespace = true

  values = [
    yamlencode({
      tenant = {
        name = "minio"
        configSecret = {
          accessKey = var.minio_access_key
          secretKey = var.minio_secret_key
        }
        pools = [for pool in var.minio_pools : {
          name    = pool.name
          servers = pool.servers
          size    = pool.size
        }]
      }
    })
  ]

  depends_on = [helm_release.minio_operator]
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

resource "kubectl_manifest" "minio_api_certificate" {
  yaml_body = <<-YAML
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: ${local.minio_api_tls_secret}
      namespace: ${local.minio_namespace}
    spec:
      secretName: ${local.minio_api_tls_secret}
      issuerRef:
        name: ${local.letsencrypt_issuer}
        kind: ClusterIssuer
      dnsNames:
        - ${var.minio_api_domain}
  YAML

  depends_on = [helm_release.minio]
}

resource "kubectl_manifest" "minio_servers_transport" {
  yaml_body = <<-YAML
    apiVersion: traefik.io/v1alpha1
    kind: ServersTransport
    metadata:
      name: ${local.minio_serv_transport}
      namespace: ${local.minio_namespace}
    spec:
      insecureSkipVerify: true
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

resource "kubectl_manifest" "minio_api_headers" {
  yaml_body = <<-YAML
    apiVersion: traefik.io/v1alpha1
    kind: Middleware
    metadata:
      name: ${local.minio_api_headers_middleware}
      namespace: ${local.minio_namespace}
    spec:
      headers:
        customRequestHeaders:
          X-Forwarded-For: ""
          X-Forwarded-Proto: "https"
  YAML

  depends_on = [helm_release.minio]
}

resource "kubectl_manifest" "minio_api_redirect" {
  yaml_body = <<-YAML
    apiVersion: traefik.io/v1alpha1
    kind: Middleware
    metadata:
      name: ${local.minio_api_redirect_https_middleware}
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
              port: 9443
              scheme: https
              serversTransport: ${local.minio_serv_transport}
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
              port: 9443
  YAML

  depends_on = [kubectl_manifest.minio_console_redirect]
}

resource "kubectl_manifest" "minio_api_ingress" {
  yaml_body = <<-YAML
    apiVersion: traefik.io/v1alpha1
    kind: IngressRoute
    metadata:
      name: minio-api
      namespace: ${local.minio_namespace}
    spec:
      entryPoints:
        - websecure
      routes:
        - match: Host(`${var.minio_api_domain}`)
          kind: Rule
          middlewares:
            - name: ${local.minio_api_headers_middleware}
          services:
            - name: minio
              port: 443
              scheme: https
              serversTransport: ${local.minio_serv_transport}
      tls:
        secretName: ${local.minio_api_tls_secret}
  YAML

  depends_on = [
    kubectl_manifest.minio_api_certificate,
    kubectl_manifest.minio_api_headers,
  ]
}

resource "kubectl_manifest" "minio_api_ingress_http" {
  yaml_body = <<-YAML
    apiVersion: traefik.io/v1alpha1
    kind: IngressRoute
    metadata:
      name: minio-api-http
      namespace: ${local.minio_namespace}
    spec:
      entryPoints:
        - web
      routes:
        - match: Host(`${var.minio_api_domain}`)
          kind: Rule
          middlewares:
            - name: ${local.minio_api_redirect_https_middleware}
          services:
            - name: minio
              port: 443
  YAML

  depends_on = [kubectl_manifest.minio_api_redirect]
}

