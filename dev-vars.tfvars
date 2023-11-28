region = "us-west-2"

vpc = {
  cidr_block = "20.0.0.0/16"
  name       = "vpc-test"
}

environment = "qa"
#profile = "test-ha"

tags = {
  "Project"          = "test",
}


subnets = {
  subnet1 = {
    type                              = "private"
    availability_zone                 = "us-west-2a"
    cidr_block                        = "20.0.0.0/28"
    transit_gateway_direct_connection = false
  }
  subnet2 = {
    type                              = "private"
    availability_zone                 = "us-west-2b"
    cidr_block                        = "20.0.0.16/28"
    transit_gateway_direct_connection = false
  }
  
}

security_groups = {
  sg-test = {
    name        = "sg-test"
    description = "Security Group test"
    ingress = [
      {
        from_port           = 0
        to_port             = 0
        protocol            = "-1"
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