#!/bin/bash

set -euo pipefail

echo "======================================"
echo " Création du Makefile"
echo "======================================"

# Vérification

if [ ! -d "infra/envs/dev" ]; then
    echo "[ERREUR] infra/envs/dev introuvable."
    echo "Lance d'abord ./05-init-terraform.sh"
    exit 1
fi

# Répertoire Make

mkdir -p make

# Configuration commune

cat > make/common.mk <<'EOF'
SHELL := /bin/bash

TF_ROOT := infra
ENV ?= dev
TF_DIR := $(TF_ROOT)/envs/$(ENV)

PLAN_FILE := tfplan
EOF

echo "[OK] make/common.mk"

# Commandes Terraform

cat > make/terraform.mk <<'EOF'
.PHONY: \
	init \
	fmt \
	fmt-check \
	validate \
	tflint \
	tfsec \
	checkov \
	security \
	plan \
	apply \
	destroy \
	clean

init:
	terraform -chdir=$(TF_DIR) init

fmt:
	terraform fmt -recursive $(TF_ROOT)

fmt-check:
	terraform fmt -check -recursive $(TF_ROOT)

validate: init
	terraform -chdir=$(TF_DIR) validate

tflint:
	tflint --chdir=$(TF_DIR) --recursive

tfsec:
	tfsec $(TF_ROOT)

checkov:
	checkov --directory $(TF_ROOT) --framework terraform --compact

security: tflint tfsec checkov

plan: validate
	terraform -chdir=$(TF_DIR) plan -out=$(PLAN_FILE)

apply:
	terraform -chdir=$(TF_DIR) apply $(PLAN_FILE)

destroy:
	terraform -chdir=$(TF_DIR) destroy

clean:
	rm -rf $(TF_DIR)/.terraform
	rm -f $(TF_DIR)/$(PLAN_FILE)
EOF

echo "[OK] make/terraform.mk"

# Makefile principal

cat > Makefile <<'EOF'
include make/common.mk
include make/terraform.mk

.PHONY: help check precommit

.DEFAULT_GOAL := help

help:
	@echo ""
	@echo "Commandes disponibles :"
	@echo ""
	@echo "  make init          Initialise Terraform"
	@echo "  make fmt           Formate le code Terraform"
	@echo "  make fmt-check     Vérifie le formatage"
	@echo "  make validate      Valide la configuration"
	@echo "  make tflint        Lance TFLint"
	@echo "  make tfsec         Lance tfsec"
	@echo "  make checkov       Lance Checkov"
	@echo "  make security      Lance les contrôles de sécurité"
	@echo "  make check         Validation + sécurité"
	@echo "  make plan          Génère un plan Terraform"
	@echo "  make apply         Applique le plan enregistré"
	@echo "  make destroy       Détruit les ressources Terraform"
	@echo "  make clean         Supprime les fichiers temporaires"
	@echo "  make precommit     Lance tous les hooks pre-commit"
	@echo ""
	@echo "Environnement courant : $(ENV)"
	@echo "Terraform : $(TF_DIR)"
	@echo ""

check: fmt-check validate security

precommit:
	pre-commit run --all-files
EOF

echo "[OK] Makefile"

# Vérification

echo
echo "=== Fichiers créés ==="
echo
echo "Makefile"
echo "make/common.mk"
echo "make/terraform.mk"

echo
echo "======================================"
echo " Makefile initialisé"
echo "======================================"
echo
echo "Pour afficher les commandes :"
echo
echo "  make help"