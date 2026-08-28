#!/bin/bash

set -euo pipefail

CONFIG_FILE=".project.env"

echo "======================================"
echo " Initialisation des fichiers du dépôt"
echo "======================================"

# Vérification du fichier de configuration

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[ERREUR] $CONFIG_FILE introuvable."
    echo
    echo "Crée le fichier avec :"
    echo
    echo 'PROJECT_NAME="azure-iac"'
    echo 'GITHUB_USERNAME="ton-utilisateur-github"'
    echo 'GIT_NAME="Prenom Nom"'
    echo 'GIT_EMAIL="prenom.nom@email.com"'
    exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

# Vérification des variables nécessaires
: "${PROJECT_NAME:?PROJECT_NAME manquant dans .project.env}"
: "${GITHUB_USERNAME:?GITHUB_USERNAME manquant dans .project.env}"
: "${GIT_NAME:?GIT_NAME manquant dans .project.env}"
: "${GIT_EMAIL:?GIT_EMAIL manquant dans .project.env}"

echo "[OK] Projet : $PROJECT_NAME"

# Répertoires

mkdir -p .github

# .gitignore

cat > .gitignore <<'EOF'
# Configuration locale

.project.env

# Terraform

.terraform/
*.tfstate
*.tfstate.*
crash.log
crash.*.log

# Variables Terraform potentiellement sensibles
*.tfvars
*.tfvars.json

# Plans Terraform
tfplan
*.tfplan
*.plan

# Secrets

.env
.env.*
*.pem
*.key
*.pfx
*.p12

# Logs

*.log

# IDE

.vscode/
.idea/

# Système

.DS_Store
Thumbs.db
EOF

echo "[OK] .gitignore"

# .editorconfig

cat > .editorconfig <<'EOF'
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{tf,hcl}]
indent_style = space
indent_size = 2

[*.{yml,yaml}]
indent_style = space
indent_size = 2

[*.sh]
indent_style = space
indent_size = 4

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
EOF

echo "[OK] .editorconfig"

# .gitattributes

cat > .gitattributes <<'EOF'
* text=auto eol=lf

*.sh text eol=lf
*.tf text eol=lf
*.hcl text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
*.md text eol=lf
*.json text eol=lf
EOF

echo "[OK] .gitattributes"

# Configuration pre-commit
# Les logiciels seront installés plus tard.

cat > .pre-commit-config.yaml <<'EOF'
repos:

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:

      - id: trailing-whitespace

      - id: end-of-file-fixer

      - id: check-yaml

      - id: check-json

      - id: check-added-large-files

      - id: check-merge-conflict

      - id: detect-private-key

  - repo: local
    hooks:

      - id: terraform-fmt
        name: terraform fmt
        entry: terraform fmt -check -recursive
        language: system
        pass_filenames: false
        files: \.tf$

      - id: gitleaks
        name: gitleaks
        entry: gitleaks protect --staged --redact
        language: system
        pass_filenames: false
EOF

echo "[OK] .pre-commit-config.yaml"

# CODEOWNERS

cat > .github/CODEOWNERS <<EOF
# Propriétaire par défaut
* @$GITHUB_USERNAME

# Terraform
*.tf @$GITHUB_USERNAME
*.hcl @$GITHUB_USERNAME

# Configuration GitHub
.github/ @$GITHUB_USERNAME

# Scripts
*.sh @$GITHUB_USERNAME
EOF

echo "[OK] .github/CODEOWNERS"

# Template Pull Request

cat > .github/pull_request_template.md <<'EOF'
## Description

Décrire les modifications réalisées.

## Vérifications

- [ ] Le code a été relu
- [ ] Le code Terraform est formaté
- [ ] Les contrôles pre-commit passent
- [ ] Aucun secret n'est présent
- [ ] Aucun fichier tfstate n'est versionné
EOF

echo "[OK] .github/pull_request_template.md"

# Exemple de configuration

cat > .project.env.example <<'EOF'
PROJECT_NAME="azure-iac"

GITHUB_USERNAME="YOUR_GITHUB_USERNAME"

GIT_NAME="Prenom Nom"
GIT_EMAIL="prenom.nom@email.com"
EOF

echo "[OK] .project.env.example"

# Résumé

echo
echo "======================================"
echo " Initialisation terminée"
echo "======================================"
echo
echo "Fichiers créés :"
echo
echo "  .gitignore"
echo "  .editorconfig"
echo "  .gitattributes"
echo "  .pre-commit-config.yaml"
echo "  .project.env.example"
echo "  .github/CODEOWNERS"
echo "  .github/pull_request_template.md"
