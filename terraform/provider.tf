terraform {
  # On spécifie la version minimun de terraform requise

  required_version = ">= 1.5.0"

  # On indique qu'om a besoin du provider AWS pour créer des ressources sur AWS

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configuration du fournisseur AWS avec la région cible

provider "aws" {
  region = "us-east-1" # Région de Paris (gratuite)
}

