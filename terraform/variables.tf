variable "region" {
  description = "Región de despliegue en AWS"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
}

variable "name" {
  description = "Nombre personalizado del servidor"
  type        = string
}

variable "open_ports" {
  description = "Lista de puertos abiertos en el Security Group"
  type        = list(number)
}

variable "disk_size" {
  description = "Tamaño del disco duro en GB"
  type        = number
}