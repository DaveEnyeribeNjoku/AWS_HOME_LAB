# AWS Cloud Homelab - David Njoku
# Déploiement simple EC2 t3.micro + VPC + Security Group + Key Pair
# Testé et validé le 22/11/2025

provider "aws" {
  region = var.aws_region
}

# VPC dédié pour le homelab
resource "aws_vpc" "homelab_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name  = "homelab-vpc"
    Owner = "David Njoku"
  }
}

# Subnet public
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.homelab_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "homelab-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.homelab_vpc.id
  tags = {
    Name = "homelab-igw"
  }
}

# Route Table + Association
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.homelab_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "homelab-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group - SSH + HTTP + tout outbound
resource "aws_security_group" "homelab_sg" {
  name        = "homelab-sg"
  description = "Security Group pour AWS Cloud Homelab - David Njoku"
  vpc_id      = aws_vpc.homelab_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
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
  tags = {
    Name = "homelab-sg"
  }
}

# EC2 t3.micro Ubuntu 22.04
resource "aws_instance" "homelab_server" {
  ami           = "ami-0c55b159cbfafe1f0"  # Ubuntu 22.04 LTS (change si région différente)
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.homelab_sg.id]
  key_name      = "homelab-key"  # à créer dans la console avant

  tags = {
    Name  = "homelab-ec2-david-njoku"
    Owner = "David Njoku"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update && apt upgrade -y
              apt install nginx -y
              echo "<h1>AWS Cloud Homelab - David Njoku @ $(hostname)</h1>" > /var/www/html/index.html
              systemctl restart nginx
              EOF
}

# Output IP publique
output "homelab_instance_public_ip" {
  value       = aws_instance.homelab_server.public_ip
  description = "IP publique de l'instance Homelab"
}
