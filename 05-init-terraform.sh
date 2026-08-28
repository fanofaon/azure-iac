#!/bin/bash

set -euo pipefail

CONFIG_FILE=".project.env"

echo "======================================"
echo " Initialisation Terraform Azure"
echo "======================================"

# Vérification du fichier projet

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[ERREUR] $CONFIG_FILE introuvable."
    exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

: "${PROJECT_NAME:?PROJECT_NAME manquant dans .project.env}"

# Répertoires

echo "[+] Création de l'arborescence Terraform"

mkdir -p infra/envs/dev

mkdir -p infra/modules/resource_group
mkdir -p infra/modules/network
mkdir -p infra/modules/security
mkdir -p infra/modules/compute

# Environnement DEV

touch infra/envs/dev/main.tf
touch infra/envs/dev/providers.tf
touch infra/envs/dev/versions.tf
touch infra/envs/dev/variables.tf
touch infra/envs/dev/outputs.tf
touch infra/envs/dev/dev.auto.tfvars.example

# Modules

MODULES=(
    resource_group
    network
    security
    compute
)

for MODULE in "${MODULES[@]}"; do

    touch "infra/modules/$MODULE/main.tf"
    touch "infra/modules/$MODULE/variables.tf"
    touch "infra/modules/$MODULE/outputs.tf"

done

# README Terraform

cat > infra/README.md <<'EOF'
# Infrastructure Terraform Azure

Ce répertoire contient l'infrastructure Azure gérée avec Terraform.

## Structure

- `envs/dev` : configuration de l'environnement de développement
- `modules/resource_group` : groupes de ressources Azure
- `modules/network` : réseau virtuel et sous-réseaux
- `modules/security` : règles de sécurité réseau
- `modules/compute` : machines virtuelles

Les fichiers `*.tfvars` contenant des valeurs locales ou sensibles ne doivent pas être versionnés.
EOF

# README des modules

cat > infra/modules/resource_group/README.md <<'EOF'
# Module resource_group

Gestion des Resource Groups Azure.
EOF

cat > infra/modules/network/README.md <<'EOF'
# Module network

Gestion du Virtual Network et des sous-réseaux Azure.
EOF

cat > infra/modules/security/README.md <<'EOF'
# Module security

Gestion des Network Security Groups Azure.
EOF

cat > infra/modules/compute/README.md <<'EOF'
# Module compute

Gestion des machines virtuelles Azure.
EOF

# Vérification

echo
echo "=== Structure créée ==="
echo

find infra -type f | sort

echo
echo "======================================"
echo " Terraform Azure initialisé"
echo "======================================"
echo
