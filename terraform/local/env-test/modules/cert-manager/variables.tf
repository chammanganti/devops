variable "name" {
    type = string
    default = "traefik"
}

variable "namespace" {
    type = string
    default = "traefik"
}

variable "release_version" {
    type = string
    default = "v1.20.0"
}

variable "values_files" {
    type = list(string)
    description = "List of values file paths to merge in order"
    default = []
}

variable "values" {
    type = any
    description = "Extra values as terraform object"
    default = {}
}
