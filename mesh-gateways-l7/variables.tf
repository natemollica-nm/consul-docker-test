variable "consul_image" {
   type = string
   default = "hashicorp/consul:latest"
   description = "Name of the Consul container image to use"
}

variable "use_cluster_id" {
   type = bool
   default = false
   description = "Whether docker resources are created with a 4 byte random id tacked on"
}

variable "consul_envoy_image" {
  type = string
  default = "consul-envoy"
  description = "Envoy image to use for client proxies"
}