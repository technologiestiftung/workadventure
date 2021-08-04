
resource "aws_vpc" "wsa-vpc" {

  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true #gives you an internal domain name
  enable_dns_hostnames = true #gives you an internal host name
  enable_classiclink   = false
  instance_tenancy     = "default"
  tags                 = local.tags

}

resource "aws_subnet" "wsa-subnet-public" {
  vpc_id                  = aws_vpc.wsa-vpc.id
  cidr_block              = "192.168.0.0/24"
  map_public_ip_on_launch = true # it makes this a public subnet
  availability_zone       = "eu-central-1a"
  tags                    = local.tags

}

# make internet gateway
resource "aws_internet_gateway" "wsa-ig" {
  vpc_id = aws_vpc.wsa-vpc.id
  tags   = local.tags

}

# make a custom route table
resource "aws_route_table" "wsa-route-table" {
  vpc_id = aws_vpc.wsa-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wsa-ig.id
  }
  tags = local.tags

}

resource "aws_route_table_association" "wsa-route-table-association" {
  subnet_id      = aws_subnet.wsa-subnet-public.id
  route_table_id = aws_route_table.wsa-route-table.id

}

resource "aws_eip" "this" {
  vpc      = true
  instance = module.ec2.id[0]
}

# resource "aws_placement_group" "web" {
#   name     = "${local.name}-hunky-dory-pg"
#   strategy = "cluster"
# }

resource "aws_network_interface" "this" {

  subnet_id = aws_subnet.wsa-subnet-public.id
}
