####################################
# Locals
####################################
locals {
  az_length = length(data.aws_availability_zones.available.names)
}

####################################
# Public Subnets
####################################
resource "aws_subnet" "public-subnets" {
  count                   = length(var.vpc.public-subnets-cidr)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc.public-subnets-cidr[count.index]
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[count.index % local.az_length]

  tags = {
    Name = "${terraform.workspace}-${var.vpc.name}-public-subnet-${count.index}"
  }
}

####################################
# Private Subnets
####################################
resource "aws_subnet" "private-subnets" {
  count                   = length(var.vpc.private-subnets-cidr)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc.private-subnets-cidr[count.index]
  map_public_ip_on_launch = "false"
  availability_zone       = data.aws_availability_zones.available.names[count.index % local.az_length]

  tags = {
    Name = "${terraform.workspace}-${var.vpc.name}-private-subnet-${count.index}"
  }
}

####################################
# Public Subnets Route Table
####################################
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc-gw.id
  }

  tags = {
    Name = "${terraform.workspace}-${var.vpc.name}-public-route-table"
  }
}

####################################
# Private Subnets Route Table
####################################
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "${terraform.workspace}-${var.vpc.name}-private-route-table"
  }
}

####################################
# VPC setup for NAT
####################################
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnets[0].id
  depends_on    = [aws_internet_gateway.vpc-gw]
  tags = {
    Name = "${terraform.workspace}-${var.vpc.name}-nat-gw"
  }
}

####################################
# Public Subnets Route Table Association
####################################
resource "aws_route_table_association" "public-subnets" {
  count          = length(var.vpc.public-subnets-cidr)
  subnet_id      = aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.public-route-table.id
}

####################################
# Private Subnets Route Table Association
####################################
resource "aws_route_table_association" "private-subnets" {
  count          = length(var.vpc.private-subnets-cidr)
  subnet_id      = aws_subnet.private-subnets[count.index].id
  route_table_id = aws_route_table.private-route-table.id
}