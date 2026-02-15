variable "project_id" { 
  type = string 
}

variable "region"     { 
    type = string
    default = "us-central1" 
}

variable "zone"       { 
  type = string
  default = "us-central1-a" 
}

variable "app_name"   { 
  type = string
  default = "telegram-bot" 
}

# Red
variable "vpc_cidr"    { 
  type = string
  default = "10.0.1.0/24" 
}

variable "allowed_ips" { 
  type = list(string)
  default = ["0.0.0.0/0"] 
}

# GitHub
variable "github_owner" { 
  type = string 
}

variable "github_repo"  { 
  type = string 
}

# VM
variable "machine_type" { 
  type = string
  default = "e2-micro" 
}

variable "boot_image"   { 
  type = string
  default = "ubuntu-os-cloud/ubuntu-2204-lts" 
}

variable "boot_size"    { 
  type = number
    default = 30 
}

# App Secrets
variable "telegram_bot_token" { 
  type      = string 
  sensitive = true 
}

variable "template_vars" {
  type    = map(any)
  default = {}
}