# cluster
> A local k8s cluster with a `registry` and `MinIO`

## Prerequisites
Install the following tools: `docker`, `kind`, `kubectl`, `terraform`, and `cloud-provider-kind`.

## What to expect
This setup creates a kubernetes in docker (kind) cluster with one control-plane node and one worker node.

MinIO is deployed inside the cluster in standalone mode.

A container registry runs in docker on port `5001`. Both the kind cluster and the registry share the same docker network.

The kubeconfig file is located at `~/.kube/kind`. Run `export KUBECONFIG=~/.kube/kind` to point your `kubectl` commands to this cluster.

## Usage
1. Run `terraform init`.
2. Run `terraform apply`. You will be asked to provide the MinIO access key and secret key.
3. Run `sudo cloud-provider-kind`.
4. Get the external IP addresses from the MinIO service:
   - port `9000` for the api
   - port `9443` for the console
