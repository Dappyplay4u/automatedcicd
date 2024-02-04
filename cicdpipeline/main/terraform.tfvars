region                        = "us-east-1"

project_name                  = "CICDPIPELINE"

vpc_cidr                      = "10.0.0.0/16"

public_subnet_az1_cidr        = "10.0.0.0/24"

public_subnet_az2_cidr        = "10.0.1.0/24"

available_zones               = "data.aws_availability_zones.available_zones.names"
