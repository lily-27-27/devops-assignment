provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}


# Subnet
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public subnet A"
  }
}

resource "aws_subnet" "public_d" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1d"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public subnet D"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Route Table
resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.public_a.id
  route_table_id = aws_route_table.routetable.id
}

# Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami                    = "ami-0c02fb55956c7d316" # Ubuntu 20.04 (us-east-1)
  instance_type          = "t2.micro"
    subnet_id = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "my-key" # Replace with your existing keypair

  tags = {
    Name = "Terraform-Web-Server"
  }
}


resource "aws_db_subnet_group" "db_subnet" {
  name       = "db-subnet-group"
  subnet_ids = [
    aws_subnet.public_a.id,
    aws_subnet.public_d.id
  ]

  tags = {
    Name = "DB subnet group"
  }
}



# RDS Database
resource "aws_db_instance" "mydb" {
  identifier              = "terraform-db"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0.35"
  instance_class          = "db.t3.micro"
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true
  publicly_accessible     = true

  vpc_security_group_ids  = [aws_security_group.web_sg.id]           # ✅ Use SG from same VPC
  db_subnet_group_name    = aws_db_subnet_group.db_subnet.name       # ✅ Link the subnet group
}
