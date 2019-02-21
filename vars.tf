variable "auth_token" {
  description = "Your Packet API key"
}

variable "facility" {
  description = "Packet Facility"
  default     = "ewr1"
}

variable "plan" {
  description = "Plan for Nodes"
  default     = "baremetal_0"
}

variable "count" {
  default     = "1"
  description = "Number of nodes of type var.plan."
}

variable "flatcar_update_url" {
  description = "Flatcar Linux Update URL"
  default     = "https://public.update.flatcar-linux.net/v1/update/"
}

variable "coreos_release_channel" {
  description = "CoreOS Release Channel (stable, alpha, beta)"
  default     = "alpha"
}

variable "install_kube_tools" {
  description = "Install CNI and CRI tooling for Kubernetes"
  default     = "no"
}

variable "cni_version" {
    description = "CNI Version (i.e. v0.6.0)"
    default = "v0.6.0"
}

variable "crictl_version" {
    description = "crictl_version release"
    default = "v1.11.1"
  
}
