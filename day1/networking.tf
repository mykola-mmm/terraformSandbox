# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  # main_route_table_id  = aws_route_table.my_vpc_route_table.id

  tags = {
    Name = "my-vpc"
  }
}

# Subnets
resource "aws_subnet" "dmz_public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  depends_on              = [aws_vpc.my_vpc]
  map_public_ip_on_launch = true

  tags = {
    Name = "dmz-public-subnet"
  }
}


resource "aws_subnet" "frontend_private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  depends_on              = [aws_vpc.my_vpc]
  map_public_ip_on_launch = false

  tags = {
    Name = "frontend-private-subnet"
  }
}

resource "aws_subnet" "backend_private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.3.0/24"
  depends_on              = [aws_vpc.my_vpc]
  map_public_ip_on_launch = false

  tags = {
    Name = "backend-private-subnet"
  }
}

resource "aws_subnet" "db_private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.4.0/24"
  depends_on              = [aws_vpc.my_vpc]
  map_public_ip_on_launch = false

  tags = {
    Name = "db-private-subnet"
  }
}

# Security Group
resource "aws_security_group" "ssh_bastion_sg" {
  name        = "ssh-bastion-sg"
  description = "Security group for SSH bastion"

  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-bastion-sg"
  }
}

# Security Group
resource "aws_security_group" "frontend_private_sg" {
  name        = "frontend-private-sg"
  description = "Security group for frontend private subnet"

  vpc_id = aws_vpc.my_vpc.id

  # Add ingress and egress rules specific to the frontend private subnet
}

resource "aws_security_group" "backend_private_sg" {
  name        = "backend-private-sg"
  description = "Security group for backend private subnet"

  vpc_id = aws_vpc.my_vpc.id

  # Add ingress and egress rules specific to the backend private subnet
}

resource "aws_security_group" "db_private_sg" {
  name        = "db-private-sg"
  description = "Security group for database private subnet"

  vpc_id = aws_vpc.my_vpc.id

  # Add ingress and egress rules specific to the database private subnet
}

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-vpc-igw"
  }
}
resource "aws_route_table" "my_vpc_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_vpc_igw.id
  }

  tags = {
    Name = "my-vpc-route-table"
  }
}

resource "aws_route_table_association" "dmz_public_subnet_association" {
  subnet_id      = aws_subnet.dmz_public_subnet.id
  route_table_id = aws_route_table.my_vpc_route_table.id
}


resource "aws_route_table_association" "frontend_private_subnet_association" {
  subnet_id      = aws_subnet.frontend_private_subnet.id
  route_table_id = aws_route_table.my_vpc_route_table.id
}

resource "aws_route_table_association" "backend_private_subnet_association" {
  subnet_id      = aws_subnet.backend_private_subnet.id
  route_table_id = aws_route_table.my_vpc_route_table.id
}

resource "aws_route_table_association" "db_private_subnet_association" {
  subnet_id      = aws_subnet.db_private_subnet.id
  route_table_id = aws_route_table.my_vpc_route_table.id
}
