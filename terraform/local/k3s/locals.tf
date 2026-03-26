locals {
  letsencrypt_issuer = "letsencrypt"

  minio_namespace                         = "minio"
  minio_console_tls_secret                = "minio-console-tls"
  minio_api_tls_secret                    = "minio-api-tls"
  minio_serv_transport                    = "minio-transport"
  minio_console_headers_middleware        = "minio-console-headers"
  minio_console_redirect_https_middleware = "minio-console-redirect-https"
  minio_api_headers_middleware            = "minio-api-headers"
  minio_api_redirect_https_middleware     = "minio-api-redirect-https"
}
