#create VPC

module "vpc" {
  source                        = "../modules/vpc"
  region                        = var.region
  project_name                  = var.project_name
  vpc_cidr                      = var.vpc_cidr
  public_subnet_az1_cidr        = var.public_subnet_az1_cidr
  public_subnet_az2_cidr        = var.public_subnet_az2_cidr
  
}

###EC2
module "ec2" {
  source                        = "../modules/ec2"
  # webserver_security_group_id   = module.securitygroup.webserver_security_group_id 
  jenkins_security_group_id     = module.securitygroup.jenkins_security_group_id 
  Nexus_security_group_id       = module.securitygroup.Nexus_security_group_id
  Prometheus_security_group_id  = module.securitygroup.Prometheus_security_group_id
  Grafana_security_group_id     = module.securitygroup.Grafana_security_group_id
  SonaQube_security_group_id    = module.securitygroup.SonaQube_security_group_id
  public_subnet_az1_id          = module.vpc.public_subnet_az1_id
  public_subnet_az2_id          = module.vpc.public_subnet_az2_id
  
}

# #NATGATEWAY
module "natgateway" {
  source                        = "../modules/natgateway"
  vpc_id                        = module.vpc.vpc_id         
  public_subnet_az1_id          = module.vpc.public_subnet_az1_id
  public_subnet_az2_id          = module.vpc.public_subnet_az2_id
  internet_gateway              = module.vpc.internet_gateway
}

#SECURITY GROUP
module "securitygroup" {
  source                        = "../modules/securitygroup"
  vpc_id                        = module.vpc.vpc_id

}
