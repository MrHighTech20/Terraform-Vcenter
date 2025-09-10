variable "vsphere_user" {
  description = "Username for vSphere authentication"
  type        = string
}

variable "vsphere_password" {
  description = "Password for vSphere authentication"
  type        = string
  sensitive   = true
}

variable "vsphere_server" {
  description = "vSphere server address"
  type        = string
}