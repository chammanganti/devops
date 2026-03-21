output "name" {
  description = "Cluster name"
  value       = kind_cluster.this.name
}

output "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  value       = kind_cluster.this.kubeconfig_path
}

output "kubeconfig" {
  description = "Raw kubeconfig content"
  value       = kind_cluster.this.kubeconfig
  sensitive   = true
}

output "endpoint" {
  description = "Kubernetes API server endpoint"
  value       = kind_cluster.this.endpoint
}
