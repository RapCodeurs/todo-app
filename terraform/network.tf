# 1. Création d'un VPC (Virtual Private Cloud) pour notre espace isolé sur AWS

resource "aws_vpc" "todo_vpc" {
  cidr_block           = "10.0.0.0/16" # Plage d'adresses IP pour tout le réseau
  enable_dns_hostnames = true          # Permet d'allouer des noms de domaines aux machines
  enable_dns_support   = true          # Permet de résoudre les noms de domaines
  tags = {
    Name = "todo-app-vpc"
  }
}

# 2. Création du Sous-réseau Public (Où résidera notre serveur EC2)

resource "aws_subnet" "todo_public_subnet" {
  vpc_id                  = aws_vpc.todo_vpc.id # On associe le sous-réseau au VPC créé précédemment
  cidr_block              = "10.0.1.0/24"       # Plage d'IP spécifique à ce sous-réseau
  availability_zone       = "us-east-1a"        # Zone de disponibilité pour la haute disponibilité (Paris A)
  map_public_ip_on_launch = true                # Permet d'attribuer automatiquement une IP publique aux instances lancées dans ce sous-réseau

  tags = {
    Name = "todo-app-public-subnet"
  }
}

# 3. Création de la Passerelle Internet (La porte vers le web extérieur)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.todo_vpc.id # On associe la passerelle Internet au VPC créé précédemment

  tags = {
    Name = "todo-app-igw"
  }
}

# 4. Création de la Table de Routage (Le guide pour orienter le trafic vers internet)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.todo_vpc.id # On associe la table de routage au VPC créé précédemment

  route {
    cidr_block = "0.0.0.0/0"                 # Signifie "Tout le trafic à destination d'internet..."
    gateway_id = aws_internet_gateway.igw.id # "...doit être envoyé vers l'Internet Gateway"
  }

  tags = {
    Name = "todo-app-public-rt"
  }
}

# 5. Association de la Table de Routage avec notre Sous-réseau Public
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.todo_public_subnet.id # On associe la table de routage au sous-réseau public
  route_table_id = aws_route_table.public_rt.id     # On associe la table de routage à l'ID de la table de routage créée précédemment
}
