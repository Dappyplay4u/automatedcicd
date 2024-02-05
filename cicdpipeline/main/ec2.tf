#configure aws profile
provider "aws" {
  region  = "us-east-1"
  profile = "terraform-user"
}

# create vpc
# terraform aws create vpc
resource "aws_vpc" "vpc" {
  cidr_block              = var.vpc_cidr
  instance_tenancy        = "default"
  enable_dns_hostnames    = true

  tags      = {
    Name    = "${var.project_name}-vpc"
  }
}

# create internet gateway and attach it to vpc
# terraform aws create internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id    = aws_vpc.vpc.id 

  tags      = {
    Name    = "${var.project_name}-igw"
  }
}

# create public subnet az1
# terraform aws create subnet
resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.vpc.id 
  cidr_block              = var.public_subnet_az1_cidr
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags      = {
    Name    = "${var.project_name}-public-subnet-az1"
  }
}

# create public subnet az2
# terraform aws create subnet
resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.vpc.id 
  cidr_block              = var.public_subnet_az2_cidr
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags      = {
    Name    = "${var.project_name}-public-subnet-az2"
  }
}

# create route table and add public route
# terraform aws create route table
resource "aws_route_table" "public_route_table" {
  vpc_id       = aws_vpc.vpc.id 

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags       = {
    Name     = "${var.project_name}-public-route-table"
  }
}

# associate public subnet az1 to "public route table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public_subnet_az1_route_table_association" {
  subnet_id           = aws_subnet.public_subnet_az1.id 
  route_table_id      = aws_route_table.public_route_table.id 
}

# associate public subnet az2 to "public route table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public_subnet_2_route_table_association" {
  subnet_id           = aws_subnet.public_subnet_az2.id 
  route_table_id      = aws_route_table.public_route_table.id 
}

# use data source to get a registered amazon linux 2 ami
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# use data source to get a registered Ubuntu 2 ami

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical account ID for Ubuntu AMIs

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM Role for Jenkins EC2 Instance
resource "aws_iam_role" "jenkins_cicd_server_role" {
  name = "jenkins-cicd-server-role"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# IAM Policy Attachment - AdministratorAccess
resource "aws_iam_policy_attachment" "jenkins_cicd_admin_policy_attachment" {
  name       = "jenkins-cicd-admin-policy-attachment"
  roles      = [aws_iam_role.jenkins_cicd_server_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

###JENKINS SERVERS PUBLIC SUBNETS
# EC2 Instance with IAM Role
resource "aws_instance" "jenkins_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.large"
  subnet_id              = aws_subnet.public_subnet_az2.id
  key_name               = "postgreskey"
  user_data              = file("jenkins-maven-ansible-setup.sh")
  iam_instance_profile   = aws_iam_role.jenkins_cicd_server_role.name  # IAM Role Name
  vpc_security_group_ids = [aws_security_group.jenkins_security_group.id]

  tags = {
    Name        = "jenkins server"
    Application = "jenkins"
  }
}

# Network Interface
resource "aws_network_interface" "main_network_interface_jenkins" {
  subnet_id = aws_subnet.public_subnet_az2.id
  tags      = {
    Name = "jenkins_network_interface"
  }
}


### NEXUS SERVERS PUBLIC SUBNETS
resource "aws_instance" "Nexus_server" {
  ami = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.medium"
  subnet_id = aws_subnet.public_subnet_az1.id
  key_name = "postgreskey"
  vpc_security_group_ids = [aws_security_group.Nexus_security_group.id]
  user_data              = file("nexus-setup.sh")
  tags = {
    Name = "Nexus server"
  }
}

resource "aws_network_interface" "main_network_interface-Nexus" {
  subnet_id   = aws_subnet.public_subnet_az1.id

  tags = {
    Name = "Nexus_network_interface"
  }
}

### Prometheus SERVERS PUBLIC SUBNETS
###SERVERS PUBLIC SUBNETS
resource "aws_instance" "Prometheus_server" {
  ami = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet_az2.id
  key_name = "postgreskey"
  vpc_security_group_ids = [aws_security_group.Prometheus_security_group.id]
  user_data              = file("prometheus-setup.sh")
  iam_instance_profile = "jenkins-cicd-server-role"
  tags = {
    Name = "Prometheus server"
  }
}

resource "aws_network_interface" "main_network_interface-Prometheus" {
  subnet_id   = aws_subnet.public_subnet_az2.id

  tags = {
    Name = "Prometheus_network_interface"
  }
}

###Grafana SERVERS PUBLIC SUBNETS
resource "aws_instance" "Grafana_server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet_az1.id
  key_name = "postgreskey"
  vpc_security_group_ids = [aws_security_group.Grafana_security_group.id]
  user_data              = file("grafana-setup.sh")
  tags = {
    Name = "Grafana server"
  }
}

resource "aws_network_interface" "main_network_interface-Grafana" {
  subnet_id   = aws_subnet.public_subnet_az1.id

  tags = {
    Name = "Grafana_network_interface"
  }
}

##SonarQube SERVERS PUBLIC SUBNETS
resource "aws_instance" "SonaQube_server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  subnet_id = aws_subnet.public_subnet_az2.id
  key_name = "postgreskey"
  vpc_security_group_ids = [aws_security_group.SonaQube_security_group.id]
  user_data              = file("SonaQube-setup.sh")
  tags = {
    Name = "SonaQube server"
  }
}

resource "aws_network_interface" "main_network_interface-SonaQube" {
  subnet_id   = aws_subnet.public_subnet_az2.id

  tags = {
    Name = "SonaQube_network_interface"
  }
}


# create security group for the jenkins instance
# terraform aws create security group
resource "aws_security_group" "jenkins_security_group" {
  name        = "alb security group"
  description = "enable jenkins/maven access on port 8080/ 9100"
  vpc_id      = aws_vpc.vpc.id 

  ingress {
    description      = "jenkins access"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "maven access"
    from_port        = 9100
    to_port          = 9100
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "jenkins security group"
  }
}

# create security group for SonaQube instance
# terraform aws create security group
resource "aws_security_group" "SonaQube_security_group" {
  name        = "SonaQube security group"
  description = "enable ssh and access on port 22 and 9000"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Sonaqube access"
    from_port        = 9000
    to_port          = 9000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "maven access"
    from_port        = 9100
    to_port          = 9100
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "SonaQube security group"
  }
}

# create security group for the web server
# terraform aws create security group
resource "aws_security_group" "webserver_security_group" {
  name        = "webserver security group"
  description = "enable http/https access on port 80/443 via alb sg and access on port 22 via ssh sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "jenkins access"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "maven access"
    from_port        = 9100
    to_port          = 9100
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
 ingress {
    description      = "HTTP Access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS Access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "webserver security group"
  }
}

# create security group for Nexus instance
# terraform aws create security group
resource "aws_security_group" "Nexus_security_group" {
  name        = "Nexus security group"
  description = "enable http/https access on port 8081/9100"
  vpc_id      = aws_vpc.vpc.id 

  ingress {
    description      = "nexus access"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "maven access"
    from_port        = 9100
    to_port          = 9100
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "Nexus security group"
  }
}

# create security group for Prometheus instance
# terraform aws create security group
resource "aws_security_group" "Prometheus_security_group" {
  name        = "Prometheus security group"
  description = "enable Prometheus access on port 9090"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Prometheus access"
    from_port        = 9090
    to_port          = 9090
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "Prometheus security group"
  }
}

# create security group for Grafana instance
# terraform aws create security group
resource "aws_security_group" "Grafana_security_group" {
  name        = "Grafana security group"
  description = "enable Grafana access on port 9090"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Grafana access"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "Grafana security group"
  }
}

# create internet gateway and attach it to vpc
# terraform aws create internet gateway
resource "aws_internet_gateway" "minecraft-internet_gateway" {
  vpc_id    = aws_vpc.vpc.id 

  tags      = {
    Name    = "${var.project_name}-igw"
  }
}

# allocate elastic ip. this eip will be used for the nat-gateway in the public subnet az1 
# terraform aws allocate elastic ip
resource "aws_eip" "eip_for_nat_gateway_az1" {
  domain = "vpc"

  tags   = {
    Name = "nat gateway az1 eip"
  }
}


# allocate elastic ip. this eip will be used for the nat-gateway in the public subnet az2
# terraform aws allocate elastic ip
resource "aws_eip" "eip_for_nat_gateway_az2" {
  domain = "vpc"

  tags   = {
    Name = "nat gateway az2 eip"
  }
}

# create nat gateway in public subnet az1
# terraform create aws nat gateway
resource "aws_nat_gateway" "nat_gateway_az1" {
  allocation_id = aws_eip.eip_for_nat_gateway_az1.id
  subnet_id     = aws_subnet.public_subnet_az1.id

  tags   = {
    Name = "nat gateway az1"
  }

  # to ensure proper ordering, it is recommended to add an explicit dependency
  # on the internet gateway for the vpc.
  depends_on = [aws_internet_gateway.minecraft-internet_gateway]
}

# create nat gateway in public subnet az2
# terraform create aws nat gateway
resource "aws_nat_gateway" "nat_gateway_az2" {
  allocation_id = aws_eip.eip_for_nat_gateway_az2.id
  subnet_id     = aws_subnet.public_subnet_az2.id

  tags   = {
    Name = "nat gateway az2"
  }

  # to ensure proper ordering, it is recommended to add an explicit dependency
  # on the internet gateway for the vpc.
  depends_on = [aws_internet_gateway.minecraft-internet_gateway]
}

