# Se especifica la versión del proveedore AWS necesario para este código.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Se configura el proveedor AWS, especificando la región y el profile.
provider "aws" {
  region  = var.region
 # profile = var.profile
}

locals {

  # Se agregan los tags de Date/Time y Environment
  tags = merge(var.tags, {
    "Date/Time"   = timeadd(timestamp(), "-6h")
    "Environment" = var.environment
  })

  # Se crea un mapa de las subnest públicas a crear
  public_subnets = {
    for subnet_name, subnet_values in var.subnets :
    subnet_name => subnet_values
    if subnet_values.type == "public"
  }

  # Se crea un mapa de las subnest privadas a crear
  private_subnets = {
    for subnet_name, subnet_values in var.subnets :
    subnet_name => subnet_values
    if subnet_values.type == "private"
  }

  # Se crea una lista que definirá cuantas tablas de rutas públicas habrá, esto se hace a partir de 
  # identificar si una subnet pública tiene rutas hacia el Internet Gateway ('var.transit_gateway_cidr_blocks'). 
  # En caso de que una subnet no tenga ninguna ruta hacia un destino específicado, se le asignará
  # la tabla de ruteo principal, que solo contiene la ruta hacia la misma VPC.
  public_route_table_definition = [
    for subnet_name, subnet_values in local.public_subnets :
    subnet_name
    if contains(keys(var.internet_gateway_cidr_blocks), subnet_name)
  ]

  # Se crea una estructura a partir de 'var.internet_gateway_cidr_blocks', que indicará cuantas rutas serán 
  # necesarias crear hacia el Internet Gateway.
  subnets_internet_cidr_blocks_list = flatten([
    for subnet_name, cidr_blocks in var.internet_gateway_cidr_blocks : [
      for cidr_block in cidr_blocks : {
        subnet_name = subnet_name
        cidr_block  = cidr_block
      }
    ]
  ])

  # Se crea un mapa a partir de 'local.subnets_internet_cidr_blocks_list' para poder identificar 
  # los valores por medio de una llave que se construye a partir de la subnet pública que requiere la ruta
  # y la ruta destino hacia el Internet Gateway.
  subnets_internet_cidr_blocks = {
    for values in local.subnets_internet_cidr_blocks_list :
    "${values.subnet_name}-${values.cidr_block}" => values
  }


  # Se crea una lista que definirá cuantas tablas de rutas privadas habrá, esto se hace a partir de 
  # identificar si una subnet privada tiene rutas  hacia el Transit Gateway ('var.transit_gateway_cidr_blocks'). 
  # En caso de que una subnet no tenga ninguna ruta hacia un destino específicado, se le asignará
  # la tabla de ruteo principal, que solo contiene la ruta hacia la misma VPC.
  

  # Se crea una estructura a partir de 'var.transit_gateway_cidr_blocks', que indicará cuantas rutas serán 
  # necesarias crear hacia el Transit Gateway.
  

  # Se crea un mapa a partir de 'local.subnets_transit_cidr_blocks_list' para poder identificar 
  # los valores por medio de una llave que se construye a partir de la subnet privada que requiere la ruta
  # y la ruta destino hacia el Transit Gateway.
  

  # Se crea una lista de las subntes privadas que tendrán conexión directa con el Transit Gateway
  

  # Se crea una estructura a partir de 'var.security_groups',  la cual contendrá cada una de las reglas de ingreso
  # de los security groups definidos, esto para poder crear y asociar las reglas posteriormente a la creación de los
  # security groups en caso de que exista una dependencia entre ellos.
  ingress_rules_list = flatten([
    for security_group_name, security_group_values in var.security_groups : [
      for ingress_rule in security_group_values.ingress : {
        security_group_name = security_group_name
        ingress_rule        = ingress_rule
        name_aux1           = ingress_rule.security_group_name != null ? ingress_rule.security_group_name : ""
        name_aux2           = ingress_rule.cidr_blocks != null ? ingress_rule.cidr_blocks[0] : ""
        name_aux3           = ingress_rule.self != null ? ingress_rule.self : ""
      }
    ]
  ])

  # Se crea un mapa a partir de 'local.ingress_rules_listt' para poder identificar 
  # los valores por medio de una llave que se construye a partir del security group que requiere la regla de ingreso,
  # el puerto fuente el puerto destino, el protocolo y cadena auxliares 
  ingress_rule = {
    for values in local.ingress_rules_list :
    "${values.security_group_name}-${values.ingress_rule.from_port}-${values.ingress_rule.to_port}-${values.ingress_rule.protocol}-${values.name_aux1}-${values.name_aux2}-${values.name_aux3}" => values
  }

  # Se crea una estructura a partir de 'var.security_groups',  la cual contendrá cada una de las reglas de egreso
  # de los security groups definidos, esto para poder crear y asociar las reglas posteriormente a la creación de los
  # security groups en caso de que exista una dependencia entre ellos.
  egress_rules_list = flatten([
    for security_group_name, security_group_values in var.security_groups : [
      for egress_rule in security_group_values.egress : {
        security_group_name = security_group_name
        egress_rule         = egress_rule
        name_aux1           = egress_rule.security_group_name != null ? egress_rule.security_group_name : ""
        name_aux2           = egress_rule.cidr_blocks != null ? egress_rule.cidr_blocks[0] : ""
        name_aux3           = egress_rule.self != null ? egress_rule.self : ""
      }
    ]
  ])

  # Se crea un mapa a partir de 'local.egress_rules_listt' para poder identificar 
  # los valores por medio de una llave que se construye a partir del security group que requiere la regla de egreso,
  # el puerto fuente el puerto destino, el protocolo y cadena auxliares 
  egress_rule = {
    for values in local.egress_rules_list :
    "${values.security_group_name}-${values.egress_rule.from_port}-${values.egress_rule.to_port}-${values.egress_rule.protocol}-${values.name_aux1}-${values.name_aux2}-${values.name_aux3}" => values
  }
}

# Crea una VPC utilizando el módulo 'Unity-VPC-module' y en caso de existir subnet públicas, crea y asocia a la VPC
# un Internet Gateway
module "vpc_module" {
  source                    = "git::https://github.com/carl0s05/vpc-module-test.git?ref=main"
  vpc_cidr_block            = var.vpc.cidr_block
  #internet_gateway_creation = length(local.public_subnets) > 0
  partial_name              = var.vpc.name
  environment               = var.environment
  tags                      = var.tags
}

# Crea una serie de subnets especificadas en 'var.subnets' utilizando el módulo 'Unity-SubNet-module'
module "subnet_module" {
  source                   = "git::https://github.com/carl0s05/subnet-module-test.git?ref=main"
  for_each                 = var.subnets
  vpc_id                   = module.vpc_module.vpc_id
  subnet_cidr_block        = each.value.cidr_block
  subnet_availability_zone = each.value.availability_zone
  subnet_type              = each.value.type
  partial_name             = "${var.vpc.name}-${each.key}"
  environment              = var.environment
  tags                     = var.tags
}

# Crea los grupos de seguridad especificados en 'var.security_groups' utilizando el módulo 'Unity-SecurityGroups-module'
# Estos serán asociados a la VPC especificadada en 'module.vpc_module.vpc_id', los grupos de seguridad se crearán sin reglas 
# asociadas, ya que si hay reglas que dependen de grupos de seguridad dentro de la VPC es necesario su previa creación.
module "security_groups_module" {
  source   = "git::https://github.com/carl0s05/sg-module-test.git?ref=main"
  for_each = var.security_groups
  vpc_id   = module.vpc_module.vpc_id
  security_group_config = {
    name        = each.value.name
    description = each.value.description
    ingress     = []
    egress      = []
  }
  partial_name = each.value.name
  environment  = var.environment
  tags         = var.tags
}


# Se crean las reglas de ingreso de los grupos de seguridad
resource "aws_security_group_rule" "ingress_security_group_rule" {
  for_each                 = local.ingress_rule
  type                     = "ingress"
  from_port                = each.value.ingress_rule.from_port
  to_port                  = each.value.ingress_rule.to_port
  protocol                 = each.value.ingress_rule.protocol
  cidr_blocks              = each.value.ingress_rule.cidr_blocks
  self                     = each.value.ingress_rule.self
  source_security_group_id = each.value.ingress_rule.security_group_name != null ? module.security_groups_module[each.value.ingress_rule.security_group_name].sg_group_id : null
  description              = each.value.ingress_rule.description
  security_group_id        = module.security_groups_module[each.value.security_group_name].sg_group_id
}


# Se crean las reglas de egreso de los grupos de seguridad
resource "aws_security_group_rule" "egress_security_group_rule" {
  for_each                 = local.egress_rule
  type                     = "egress"
  from_port                = each.value.egress_rule.from_port
  to_port                  = each.value.egress_rule.to_port
  protocol                 = each.value.egress_rule.protocol
  cidr_blocks              = each.value.egress_rule.cidr_blocks
  self                     = each.value.egress_rule.self
  source_security_group_id = each.value.egress_rule.security_group_name != null ? module.security_groups_module[each.value.egress_rule.security_group_name].sg_group_id : null
  description              = each.value.egress_rule.description
  security_group_id        = module.security_groups_module[each.value.security_group_name].sg_group_id
}

# Crea una asociación de la VPC y las subnets de la misma con el Transit Gateway definido por el identificador de la variable
# 'var.transit_gateway_id', para la creación de este, debe de existir al menos una subnet que se con conexión directa


# Crea la tabla de ruteo principal de la VPC, a esta tabla se asociarán las subnets que no requieran una tabla
# de ruteo con rutas fura de la VPC
resource "aws_default_route_table" "main_route_table" {
  default_route_table_id = module.vpc_module.default_route_table_id
  # Define las etiquetas para el NAT gateway, incluyendo una etiqueta 'Name'
  tags = merge(var.tags, {
    "Name"         = "rtb-${var.environment}-${var.vpc.name}",
    "Service Name" = "rtb",
  })
  # Ignora los cambias en la etiqueta 'Date/Time', dado que esta solo se considera al momento de la creación de los recursos
  lifecycle {
    ignore_changes = [tags["Date/Time"]]
  }
  # Especifica una dependencia explícita con la VPC garantizando 
  # que se cree el recurso posterior a las dependencias.
  depends_on = [
    module.vpc_module,
  ]
}

# Crea las tablas de rutas para las subnets públicas a partir de 'local.public_route_table_definition' 
# y la asocia a la VPC creada en el modulo 'Unity-VPC-module'.
resource "aws_route_table" "public_route_table" {
  for_each = toset(local.public_route_table_definition)
  vpc_id   = module.vpc_module.vpc_id
  # Define las etiquetas para la tabla de rutas, incluyendo una etiqueta 'Name'.
  tags = merge(var.tags, {
    "Name"         = "rtb-${var.environment}-${var.vpc.name}-${each.key}",
    "Service Name" = "rtb",
  })
  # Ignora los cambias en la etiqueta 'Date/Time', dado que esta solo se considera al momento de la creación de los recursos
  lifecycle {
    ignore_changes = [tags["Date/Time"]]
  }
  # Especifica una dependencia explícita con la VPC garantizando que se cree el recurso posterior a dicha dependencia.
  depends_on = [module.vpc_module]
}

# Crea las tablas de rutas para las subnets privadas a partir de 'local.private_route_table_definition' 
# y la asocia a la VPC creada en el modulo 'Unity-VPC-module'.


# Crea las rutas para las subnets publicas hacia los bloques de CIDR que ser dirigidos al Internet Gateway y se agregan a  las tablas 
# de las subnets públicas. Las rutas estan definidas en 'local.subnets_internet_cidr_blocks'.
/*resource "aws_route" "internet_route" {
  for_each               = local.subnets_internet_cidr_blocks
  route_table_id         = aws_route_table.public_route_table[each.value.subnet_name].id
  destination_cidr_block = each.value.cidr_block
  gateway_id             = module.vpc_module.internet_gateway_id
  # Especifica una dependencia explícita con la tabla de rutas  garantizando que se cree el 
  # recurso posterior a dicha dependencia.
  depends_on = [
    aws_route_table.public_route_table,
  ]
}*/

# Crea las rutas para las subnets privadas hacia los bloques de CIDR que ser dirigidos al Transit Gateway y se agregan a  las tablas 
# de las subnets privadas. Las rutas estan definidos en 'local.subnets_transit_cidr_blocks'.


# Asocia cada subnet públuca con su respectiva tabla de rutas 
resource "aws_route_table_association" "public_route_table_association" {
  for_each       = toset(local.public_route_table_definition)
  subnet_id      = module.subnet_module[each.key].subnet_id
  route_table_id = aws_route_table.public_route_table[each.key].id
  # Especifica una dependencia explícita con las subnets y la tabla de rutas garantizando que se cree el 
  # recurso posterior a dicha dependencia.
  depends_on = [
    module.subnet_module,
    aws_route_table.public_route_table
  ]
}