output "name" {
  description = "Helm release name"
  value       = helm_release.this.name
}

output "namespace" {
  description = "Namespace of Traefik"
  value       = helm_release.this.namespace
}

output "version" {
  description = "Chart version"
  value       = helm_release.this.version
}

output "status" {
  description = "Helm release status"
  value       = helm_release.this.status
}
