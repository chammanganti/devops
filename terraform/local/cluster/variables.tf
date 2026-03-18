variable "minio_access_key" {
    type = string
    description = "MinIO access key"
    sensitive = true
}

variable "minio_secret_key" {
    type = string
    description = "MinIO secret key"
    sensitive = true
}
