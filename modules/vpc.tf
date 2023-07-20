# VPC

# Create a VPC
resource "aws_vpc" "private_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create a subnet within the VPC
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.private_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false
}

# Create an internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.private_vpc.id
}

# Create a routing table
resource "aws_route_table" "internet" {
  vpc_id = aws_vpc.private_vpc.id
}

# Associate the subnet with the internet gateway using the default route table
resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.internet.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.igw.id
}

# Associate the route table with the subnet
resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.internet.id
}