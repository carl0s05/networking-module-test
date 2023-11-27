region = "us-west-2"

vpc = {
  cidr_block = "20.0.0.64/28"
  name       = "vpc-test"
}

environment = "dev"
/*
tags = {
  "Application Role" = "networking",
  "Project"          = "Unity",
  "Owner"            = "Brenda Pichardo",
  "Cost Center"      = "Pendiente",
  "Business Unit"    = "Apolo"
}
*/

subnets = {
  subnet1 = {
    type                              = "public"
    availability_zone                 = "us-east-1a"
    cidr_block                        = "20.0.0.0/28"
    transit_gateway_direct_connection = false
  }
  subnet2= {
    type                              = "public"
    availability_zone                 = "us-east-1b"
    cidr_block                        = "20.0.0.32/28"
    transit_gateway_direct_connection = true
  }
  
}

security_groups = {
  sg-test = {
    name        = "apolo-postgres-rds"
    description = "Security Group para RDS PostgreSQL"
    ingress = [
      {
        from_port           = 80
        to_port             = 80
        protocol            = "http"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la comunicacion a Internet"
      }
    ]
    egress = [
      {
        from_port           = 0
        to_port             = 0
        protocol            = "-1"
        cidr_blocks         = ["0.0.0.0/0"]
        self                = null
        security_group_name = null
        description         = "Permite la salida hacia el Transit Gateway"
      }
    ]
  }
}

