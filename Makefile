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

include make/github.mk
