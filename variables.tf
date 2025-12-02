variable "vm_regions" {
  type = list(string)
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s_v2"
}
