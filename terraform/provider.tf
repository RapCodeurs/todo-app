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

  backend "s3" {
    bucket         = "rapcodeurs-terraform-state-2026" # Mettez le NOM EXACT de votre bucket créé ci-dessus
    key            = "global/s3/terraform.tfstate"     # Chemin du fichier au sein du bucket S3
    region         = "us-east-1"
    dynamodb_table = "todo-app-tf-locks" # Nom exact de la table DynamoDB pour le lock
    encrypt        = true                # Force le chiffrement du state au repos
  }
}

# Configuration du fournisseur AWS avec la région cible

provider "aws" {
  region = "us-east-1" # Région de Paris (gratuite)
}

