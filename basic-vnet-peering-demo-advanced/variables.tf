# Placeholder for variables
variable "vm_size" {
  description = "The size of the Azure Virtual Machine"
  type        = string
  default     = "Standard_B1s"

  validation {
    condition = contains([
      "Standard_B1s",
      "Standard_B2s",
      "Standard_D2s_v3",
      "Standard_D4s_v3"
    ], var.vm_size)

    error_message = "Allowed VM sizes are: Standard_B1s, Standard_B2s, Standard_D2s_v3, and Standard_D4s_v3."
  }
}


variable "admin_username" {
  description = "Admin username for the virtual machines"
  type        = string
}

variable "admin_password" {
  description = "Password for the admin user"
  type        = string
  sensitive   = true
}

variable "regions" {
  type = map(object({
    location        = string
    address_space   = string
    subnet_prefix   = string
  }))

  default = {
    sea = {
      location        = "Southeast Asia"
      address_space   = "10.1.0.0/20"
      subnet_prefix   = "10.1.1.0/24"
    },
    eastasia = {
      location        = "East Asia"
      address_space   = "10.2.0.0/20"
      subnet_prefix   = "10.2.1.0/24"
    }
  }
}

