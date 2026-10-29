# --- Étape 1 : Build (Installation des dépendances) ---
FROM python:3.12-slim AS builder

WORKDIR /app

# Installer les outils nécessaires si besoin, puis compiler les dépendances
RUN apt-get update && apt-get install -y --no-install-recommends gcc g++ && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
# Installer les dépendances dans un dossier local pour pouvoir les copier facilement
RUN pip install --no-cache-dir --user -r requirements.txt


# --- Étape 2 : Image finale légère et sécurisée ---
FROM python:3.12-slim

WORKDIR /app

# Créer un utilisateur non-root dédié pour l'application
RUN useradd -u 1000 app && mkdir -p /home/app && chown -R app:app /home/app

# Copier les dépendances installées depuis l'étape précédente
COPY --from=builder /root/.local /home/app/.local
# Copier le code de l'application
COPY app/ ./app

# Mettre à jour le PATH pour que Python trouve les paquets copiés
ENV PATH=/home/app/.local/bin:$PATH

# Basculer sur l'utilisateur non-root
USER app

EXPOSE 8000

# Lancer uvicorn sur l'adresse 0.0.0.0 pour qu'il soit joignable depuis l'extérieur du conteneur
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
