# --- vpc/main.tf ---

data "aws_availability_zones" "available" {}

resource "random_integer" "random" {
min = 1
max = 100
}

resource "aws_vpc" "fbn_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "fbn_vpc-${random_integer.random.id}"

  }
}

resource "aws_subnet" "fbn_public_subnet" {
    count = length(var.public_cidrs)
    vpc_id = aws_vpc.fbn_vpc.id
    cidr_block = var.public_cidrs[count.index]
    map_public_ip_on_launch = true
    availability_zone       = ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"][count.index]

    tags = {
        Name = "fbn_public_${count.index + 1}"
    }
}



resource "aws_subnet" "fbn_private_subnet" {
    
    count = length(var.private_cidrs)
    vpc_id = aws_vpc.fbn_vpc.id
    cidr_block = var.private_cidrs[count.index]
    availability_zone       = ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"][count.index]

    tags = {
        Name = "fbn_private_${count.index + 1}"
    }
}




resource "aws_internet_gateway" "fbn_internet_gateway" {
    vpc_id = aws_vpc.fbn_vpc.id
    
    tags = {
        Name = "fbn_igw"
    }
}

resource "aws_route_table" "fbn_public_rt" {
    vpc_id = aws_vpc.fbn_vpc.id

    tags = {
        Name = "fbn_public"
    }
}

resource "aws_route" "default_route" {
    route_table_id = aws_route_table.fbn_public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fbn_internet_gateway.id
}

resource "aws_default_route_table" "fbn_private_rt" {
    default_route_table_id = aws_vpc.fbn_vpc.default_route_table_id

    tags = {
        Name = "fbn_private"
    }
}

resource "aws_subnet" "nat_gateway" {
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.123.6.0/24"
  vpc_id = aws_vpc.fbn_vpc.id
  tags = {
    "Name" = "SubnetNAT"
  }
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.nat_gateway.id
  tags = {
    "Name" = "NatGateway"
  }
}


