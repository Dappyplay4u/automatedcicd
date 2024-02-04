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
  subnet_id     = var.public_subnet_az1_id

  tags   = {
    Name = "nat gateway az1"
  }

  # to ensure proper ordering, it is recommended to add an explicit dependency
  # on the internet gateway for the vpc.
  depends_on = [var.internet_gateway]
}

# create nat gateway in public subnet az2
# terraform create aws nat gateway
resource "aws_nat_gateway" "nat_gateway_az2" {
  allocation_id = aws_eip.eip_for_nat_gateway_az2.id
  subnet_id     = var.public_subnet_az2_id

  tags   = {
    Name = "nat gateway az2"
  }

  # to ensure proper ordering, it is recommended to add an explicit dependency
  # on the internet gateway for the vpc.
  depends_on = [var.internet_gateway]
}
