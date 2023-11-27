output "vpc_id" {
  description = "Identificador de la VPC generada"
  value       = module.vpc_module.vpc_id
}

output "subnets_id" {
  description = "Identificadores de las subnets creadas"
  value = {
    for subnet_name, subnet_values in module.subnet_module :
    subnet_name => subnet_values.subnet_id
  }
}




