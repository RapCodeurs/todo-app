# 1. Création du Groupe de Sécurité (Pare-feu)

resource "aws_security_group" "todo_sg" {
  name        = "todo-app-sg"
  description = "Autoriser le trafic de base pour notre application"
  vpc_id      = aws_vpc.todo_vpc.id

  # Règle SSH (Port 22) pour permettre l'accès à distance à notre serveur EC2
  ingress {
    description = "Autoriser le trafic SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Autoriser le trafic SSH de n'importe quelle adresse IP
  }

  # Règle HTTP (Port 80) pour permettre l'accès à notre application web
  ingress {
    description = "Autoriser le trafic HTTP standard"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Autoriser le trafic HTTP de n'importe quelle adresse IP
  }

  # Règle API FastAPI (Port 8000) pour permettre l'accès à notre API FastAPI
  ingress {
    description = "Autoriser le trafic API FastAPI"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Autoriser le trafic API FastAPI de n'importe quelle adresse IP
  }

  # Règle de sortie : On autorise le serveur à aller sur internet (ex: pour télécharger des mises à jour)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 signifie "tous les protocoles"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "todo-app-sg"
  }
}

# Déclaration de la clé SSH publique locale vers AWS
resource "aws_key_pair" "todo_key" {
  key_name   = "todo-app-key"
  public_key = file("~/.ssh/todo_app_key.pub")
}


# 2. Création de l'Instance EC2 (Notre serveur virtuel)

resource "aws_instance" "todo_server" {
  ami           = "ami-0e2c8caa4b6378d8c" # ID pour Ubuntu 24.04 LTS en eu-west-3 (Paris). 
  instance_type = "t2.micro"              # Type d'instance inclus dans l'offre gratuite (Free Tier)

  subnet_id              = aws_subnet.todo_public_subnet.id
  vpc_security_group_ids = [aws_security_group.todo_sg.id]


  # ➔ AJOUTEZ CETTE LIGNE ICI :
  key_name = aws_key_pair.todo_key.key_name

  # Script de démarrage automatique (User Data)
  # Ce script va s'exécuter à l'allumage du serveur pour installer automatiquement Docker
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              EOF

  tags = {
    Name = "todo-app-server"
  }
}

# 3. Afficher l'IP publique du serveur après le déploiement
output "server_public_ip" {
  description = "L'adresse IP publique de votre serveur EC2"
  value       = aws_instance.todo_server.public_ip
}


