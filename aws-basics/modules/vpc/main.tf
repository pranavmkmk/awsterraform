data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name = "tf-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  count = 3
  cidr_block = cidrsubnet(var.vpc_cidr,8,count.index) 
  availability_zone = element(data.aws_availability_zones.available.names,count.index)
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
    }
}

resource "aws_route_table_association" "public_subnet_association" {
  count = 3
  subnet_id      = element(aws_subnet.main,count.index).id
  route_table_id = aws_route_table.public_route.id
}
