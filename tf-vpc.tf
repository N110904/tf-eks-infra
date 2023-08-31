resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env}-${var.eks_cluster_name}"
  }
}

resource "aws_subnet" "public_subnets" {
  count = 2
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.${count.index + 1}.0/24"
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index) 
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-${var.eks_cluster_name}"
  }
}

resource "aws_subnet" "private_subnets" {
  count = 2
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.${count.index + 3}.0/24"
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index) 
  tags = {
    Name = "${var.env}-${var.eks_cluster_name}"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
   Name = "${var.env}-${var.eks_cluster_name}"
  }
}

resource "aws_eip" "nat_eip" {
  count = 2
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  count = 2

  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "${var.env}-${var.eks_cluster_name}"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "${var.env}-${var.eks_cluster_name}"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_gateway[*].id, 0)
}

resource "aws_route_table_association" "public_subnet_associations" {
  count = 2
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_associations" {
  count = 2
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}