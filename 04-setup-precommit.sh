#!/bin/bash

set -euo pipefail

echo "======================================"
echo " Configuration de pre-commit"
echo "======================================"

# Vérification : dépôt Git

if [ ! -d ".git" ]; then
    echo "[ERREUR] Aucun dépôt Git détecté."
    echo "Lance d'abord le script d'initialisation Git."
    exit 1
fi

echo "[OK] Dépôt Git détecté"

# Vérification : configuration pre-commit

if [ ! -f ".pre-commit-config.yaml" ]; then
    echo "[ERREUR] .pre-commit-config.yaml introuvable."
    echo "Lance d'abord le script d'initialisation du dépôt."
    exit 1
fi

echo "[OK] .pre-commit-config.yaml détecté"

# Vérification des logiciels nécessaires

REQUIRED_TOOLS=(
    git
    pre-commit
    terraform
    gitleaks
)

ERRORS=0

echo
echo "=== Vérification des outils ==="

for TOOL in "${REQUIRED_TOOLS[@]}"; do

    if command -v "$TOOL" >/dev/null 2>&1; then
        echo "[OK] $TOOL"
    else
        echo "[MANQUANT] $TOOL"
        ERRORS=$((ERRORS + 1))
    fi

done

if [ "$ERRORS" -ne 0 ]; then
    echo
    echo "[ERREUR] $ERRORS outil(s) manquant(s)."
    echo "Lance d'abord le script 01-install-tools.sh."
    exit 1
fi

# Installation du hook Git

echo
echo "=== Activation du hook pre-commit ==="

pre-commit install

echo "[OK] Hook pre-commit activé"

# Vérification du hook

HOOK_FILE=".git/hooks/pre-commit"

if [ -x "$HOOK_FILE" ]; then
    echo "[OK] Hook présent : $HOOK_FILE"
else
    echo "[ERREUR] Le hook pre-commit n'a pas été créé."
    exit 1
fi

# Validation de la configuration

echo
echo "=== Validation de la configuration ==="

pre-commit validate-config

echo "[OK] Configuration valide"

# Premier contrôle

echo
echo "=== Exécution des contrôles ==="

pre-commit run --all-files

echo
echo "======================================"
echo " Pre-commit configuré"
echo "======================================"
echo
echo "Le hook sera maintenant exécuté"
echo "automatiquement avant chaque commit."