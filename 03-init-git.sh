#!/bin/bash

set -euo pipefail

CONFIG_FILE=".project.env"

echo "======================================"
echo " Initialisation Git locale"
echo "======================================"

# Vérification configuration

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[ERREUR] $CONFIG_FILE introuvable."
    exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

: "${PROJECT_NAME:?PROJECT_NAME manquant}"
: "${GIT_NAME:?GIT_NAME manquant}"
: "${GIT_EMAIL:?GIT_EMAIL manquant}"

# Vérification des fichiers du script 01

if [ ! -f ".gitignore" ]; then
    echo "[ERREUR] .gitignore absent."
    echo "Lance d'abord ./01-init-repo.sh"
    exit 1
fi

if [ ! -f ".pre-commit-config.yaml" ]; then
    echo "[ERREUR] .pre-commit-config.yaml absent."
    echo "Lance d'abord ./01-init-repo.sh"
    exit 1
fi

# Initialisation Git

if [ ! -d ".git" ]; then
    echo "[+] Initialisation du dépôt Git"
    git init
else
    echo "[OK] Dépôt Git déjà initialisé"
fi

# Branche principale

git branch -M main

echo "[OK] Branche principale : main"

# Identité Git locale

git config user.name "$GIT_NAME"
git config user.email "$GIT_EMAIL"

echo
echo "[OK] Identité Git locale configurée"
echo "     Nom   : $(git config user.name)"
echo "     Email : $(git config user.email)"

# Configuration Git locale

git config core.autocrlf false

echo "[OK] Fin de lignes gérées par .gitattributes"

# Premier commit

echo
echo "=== Préparation du premier commit ==="

git add .

if git diff --cached --quiet; then

    echo "[OK] Aucun changement à committer"

else

    git commit -m "chore: initialize repository"

    echo "[OK] Premier commit créé"

fi

# Informations

echo
echo "======================================"
echo " État du dépôt"
echo "======================================"
echo

git status --short

echo
echo "Branche :"
git branch --show-current

echo
echo "Derniers commits :"
git log --oneline --decorate -5 2>/dev/null || true

echo
echo "======================================"
echo " Git initialisé"
echo "======================================"
