/*variable "profile" {
  description = "Nombre de perfil para el despliegue de la infraestructura"
  type        = string
}*/

variable "region" {
  description = "Región en la que se desplegarán los recursos AWS"
  type        = string
}



variable "vpc" {
  description = "Estructura que contendrá el nombre y el bloque CIDR de la VPC"
  type = object({
    name       = string
    cidr_block = string
  })
}

variable "subnets" {
  description = "Estructura que contedrá las subnets en forma de objeto que serán creadas en la configuración, se especifica como llave de cada objeto el nombre de la subnet y dentro de cada objeto se especifica el correspondiente bloque CIDR, la availability zone, tipo de Subnet, si dicha Subnet tiene acceso a internet y si la Subnte tiene conexión directa con el Transit Gateway"
  type = map(object({
    cidr_block                        = string
    availability_zone                 = string
    type                              = string
    transit_gateway_direct_connection = bool
  }))
}

variable "security_groups" {
  description = "Mapa de los grupos de seguridad que se crearán para la VPC, cada grupo de seguridad está representado por un objeto con los campos de nombre, descripción, reglas de tráfico entrante (ingress) y reglas de tráfico saliente (egress)"
  type = map(object({
    name        = string
    description = string
    ingress = set(object({
      from_port           = number
      to_port             = number
      protocol            = string
      cidr_blocks         = list(string)
      self                = bool
      security_group_name = string
      description         = string
    }))
    egress = set(object({
      from_port           = number
      to_port             = number
      protocol            = string
      cidr_blocks         = list(string)
      self                = bool
      security_group_name = string
      description         = string
    }))
  }))
}

variable "internet_gateway_cidr_blocks" {
  description = "Mapa subnets publicas que necesitan rutas de acceso al Internet Gateway"
  type        = map(set(string))
  default     = {}
}


variable "environment" {
  description = "Variable utilizada para el nombrado estándar de los recursos (RESORCE-ENVIROMENT)"
  type        = string
}

variable "tags" {
  description = "Etiquetas base para los recursos, adicionalmente se asignará la etiqueta Name"
  type        = map(string)
}