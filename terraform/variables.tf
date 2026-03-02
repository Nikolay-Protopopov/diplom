variable "cloud_id" { type = string }
variable "folder_id" { type = string }

variable "default_zone" {
  type    = string
  default = "ru-central1-a"
}

variable "zones" {
  description = "Две зоны для веб-серверов"
  type        = list(string)
  default     = ["ru-central1-a", "ru-central1-b"]
}

variable "admin_cidr" {
  description = "CIDR для доступа администратора (например 1.2.3.4/32)"
  type        = string
}

variable "ssh_public_key" {
  description = "Публичный ключ для доступа по SSH"
  type        = string
}

variable "image_family" {
  description = "Образ ОС"
  type        = string
  default     = "ubuntu-2404-lts"
}
