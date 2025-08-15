terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Define o Security Group (Firewall) que será usado por ambas as instâncias
resource "aws_security_group" "lacrei_sg" {
  name        = "lacrei-webserver-sg"
  description = "Permite tráfego SSH, HTTP e HTTPS"

  # Regra de entrada para SSH (Porta 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Permite acesso administrativo via SSH"
  }

  # Regra de entrada para HTTP (Porta 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Permite tráfego web (redirecionamento para HTTPS)"
  }

  # Regra de entrada para HTTPS (Porta 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Permite tráfego web seguro"
  }

  # Regra de saída: permite que o servidor se conecte com o mundo exterior
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lacrei-webserver-sg"
  }
}

# Busca dinamicamente a AMI (imagem do sistema operacional) mais recente do Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (empresa por trás do Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- IAM Role para Logs do CloudWatch ---

resource "aws_iam_role" "ec2_cloudwatch_role" {
  name = "EC2-CloudWatch-Logs-Role"

  # Política de confiança que permite que o serviço EC2 "assuma" esta role
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Anexa a política gerenciada pela AWS à Role que criamos
resource "aws_iam_role_policy_attachment" "cloudwatch_attachment" {
  role       = aws_iam_role.ec2_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# Cria o "perfil da instância", que é o que de fato é anexado à EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2-CloudWatch-Logs-Role-Profile"
  role = aws_iam_role.ec2_cloudwatch_role.name
}

# --- Instâncias EC2 (Staging e Produção) ---

# Define a Instância EC2 para o ambiente de Staging
resource "aws_instance" "staging_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "lacrei-devops-key"
  vpc_security_group_ids = [aws_security_group.lacrei_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "lacrei-staging-server"
  }
}

# Define a Instância EC2 para o ambiente de Produção
resource "aws_instance" "production_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "lacrei-devops-key"
  vpc_security_group_ids = [aws_security_group.lacrei_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "lacrei-production-server"
  }
}

# --- IPs Elásticos (Fixos) ---

# Aloca um IP Fixo para o Staging e o associa à instância
resource "aws_eip" "staging_eip" {
  instance = aws_instance.staging_server.id
  tags = {
    Name = "eip-lacrei-staging"
  }
}

# Aloca um IP Fixo para a Produção e o associa à instância
resource "aws_eip" "production_eip" {
  instance = aws_instance.production_server.id
  tags = {
    Name = "eip-lacrei-production"
  }
}

