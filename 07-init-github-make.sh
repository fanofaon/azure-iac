#!/bin/bash

set -euo pipefail

echo "======================================"
echo " Configuration Make / GitHub"
echo "======================================"

# Vérifications

if [ ! -f ".project.env" ]; then
    echo "[ERREUR] .project.env introuvable."
    exit 1
fi

if [ ! -f "Makefile" ]; then
    echo "[ERREUR] Makefile introuvable."
    exit 1
fi

mkdir -p make

# github.mk

cat > make/github.mk <<'EOF'
# Configuration GitHub

include .project.env

GITHUB_REPO := $(GITHUB_USERNAME)/$(PROJECT_NAME)
VISIBILITY ?= public

.PHONY: \
	gh-login \
	gh-status \
	gh-create \
	gh-push \
	gh-open \
	gh-protect-main \
	gh-protection-status

# Authentification

gh-login: ## Connexion à GitHub CLI
	gh auth login

gh-status: ## Vérifie la connexion GitHub
	gh auth status

# Création du dépôt distant

gh-create: ## Crée le dépôt GitHub et pousse main
	gh repo create $(GITHUB_REPO) \
		--$(VISIBILITY) \
		--source=. \
		--remote=origin \
		--push

# Push

gh-push: ## Pousse la branche courante
	git push -u origin $$(git branch --show-current)

# Ouvrir le dépôt

gh-open: ## Ouvre le dépôt GitHub
	gh repo view --web

# Protection de main

gh-protect-main: ## Protège main et impose les Pull Requests
	gh api \
		--method PUT \
		-H "Accept: application/vnd.github+json" \
		-H "X-GitHub-Api-Version: 2026-03-10" \
		/repos/$(GITHUB_REPO)/branches/main/protection \
		--input - <<'JSON'
	{
	  "required_status_checks": null,
	  "enforce_admins": true,
	  "required_pull_request_reviews": {
	    "dismiss_stale_reviews": true,
	    "require_code_owner_reviews": false,
	    "required_approving_review_count": 0,
	    "require_last_push_approval": false
	  },
	  "restrictions": null,
	  "required_linear_history": true,
	  "allow_force_pushes": false,
	  "allow_deletions": false,
	  "block_creations": false,
	  "required_conversation_resolution": true,
	  "lock_branch": false,
	  "allow_fork_syncing": false
	}
	JSON

# Vérifier la protection

gh-protection-status: ## Affiche la protection de main
	gh api \
		/repos/$(GITHUB_REPO)/branches/main/protection
EOF

echo "[OK] make/github.mk"

# Ajouter l'include au Makefile

if ! grep -q '^include make/github.mk' Makefile; then
    echo "" >> Makefile
    echo "include make/github.mk" >> Makefile
fi

echo "[OK] Makefile mis à jour"

# Résumé

echo
echo "======================================"
echo " Configuration GitHub prête"
echo "======================================"

echo
echo "Commandes disponibles :"
echo
echo "  make gh-login"
echo "  make gh-status"
echo "  make gh-create"
echo "  make gh-push"
echo "  make gh-open"
echo "  make gh-protect-main"
echo "  make gh-protection-status"