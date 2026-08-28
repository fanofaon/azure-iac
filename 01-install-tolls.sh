#!/bin/bash

set -euo pipefail

echo "======================================"
echo " Installation des outils IaC"
echo "======================================"

# Vérification du système

if [ ! -f /etc/os-release ]; then
    echo "[ERREUR] Impossible de détecter le système."
    exit 1
fi

source /etc/os-release

case "${ID:-}" in
    ubuntu|debian)
        ;;
    *)
        echo "[ERREUR] Ce script supporte uniquement Debian/Ubuntu."
        exit 1
        ;;
esac

echo "[OK] Système détecté : $PRETTY_NAME"

# Vérification sudo

if [ "$EUID" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
    sudo -v
fi

# Architecture

ARCH=$(dpkg --print-architecture)

case "$ARCH" in
    amd64)
        TFLINT_ARCH="amd64"
        TFSEC_ARCH="amd64"
        GITLEAKS_ARCH="x64"
        ;;
    arm64)
        TFLINT_ARCH="arm64"
        TFSEC_ARCH="arm64"
        GITLEAKS_ARCH="arm64"
        ;;
    *)
        echo "[ERREUR] Architecture non supportée : $ARCH"
        exit 1
        ;;
esac

echo "[OK] Architecture : $ARCH"

# Paquets système de base

echo
echo "=== Outils système ==="

$SUDO apt-get update

$SUDO apt-get install -y \
    git \
    make \
    curl \
    wget \
    unzip \
    ca-certificates \
    gnupg \
    lsb-release \
    jq \
    python3 \
    python3-pip \
    pipx \
    shellcheck \
    golang-go \
    docker.io \
    gh

echo "[OK] Outils système installés"

# Terraform

echo
echo "=== Terraform ==="

if command -v terraform >/dev/null 2>&1; then

    echo "[OK] Terraform déjà installé"

else

    wget -O- https://apt.releases.hashicorp.com/gpg |
        gpg --dearmor |
        $SUDO tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null

    CODENAME="${UBUNTU_CODENAME:-}"

    if [ -z "$CODENAME" ]; then
        CODENAME=$(lsb_release -cs)
    fi

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $CODENAME main" |
        $SUDO tee /etc/apt/sources.list.d/hashicorp.list >/dev/null

    $SUDO apt-get update
    $SUDO apt-get install -y terraform

    echo "[OK] Terraform installé"

fi

# Azure CLI

echo
echo "=== Azure CLI ==="

if command -v az >/dev/null 2>&1; then

    echo "[OK] Azure CLI déjà installé"

else

    $SUDO mkdir -p /etc/apt/keyrings

    curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
        gpg --dearmor |
        $SUDO tee /etc/apt/keyrings/microsoft.gpg >/dev/null

    $SUDO chmod go+r /etc/apt/keyrings/microsoft.gpg

    AZ_DIST=$(lsb_release -cs)

    cat <<EOF | $SUDO tee /etc/apt/sources.list.d/azure-cli.sources >/dev/null
Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: ${AZ_DIST}
Components: main
Architectures: $(dpkg --print-architecture)
Signed-by: /etc/apt/keyrings/microsoft.gpg
EOF

    $SUDO apt-get update
    $SUDO apt-get install -y azure-cli

    echo "[OK] Azure CLI installé"

fi

# Trivy

echo
echo "=== Trivy ==="

if command -v trivy >/dev/null 2>&1; then

    echo "[OK] Trivy déjà installé"

else

    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key |
        gpg --dearmor |
        $SUDO tee /usr/share/keyrings/trivy.gpg >/dev/null

    echo \
        "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" |
        $SUDO tee /etc/apt/sources.list.d/trivy.list >/dev/null

    $SUDO apt-get update
    $SUDO apt-get install -y trivy

    echo "[OK] Trivy installé"

fi

# Applications Python avec pipx

echo
echo "=== Outils Python ==="

export PATH="$HOME/.local/bin:$PATH"

pipx ensurepath >/dev/null 2>&1 || true

install_pipx_tool() {

    COMMAND="$1"
    PACKAGE="$2"

    if command -v "$COMMAND" >/dev/null 2>&1; then
        echo "[OK] $COMMAND déjà installé"
    else
        echo "[+] Installation de $PACKAGE"
        pipx install "$PACKAGE"
    fi
}

install_pipx_tool "pre-commit" "pre-commit"
install_pipx_tool "checkov" "checkov"
install_pipx_tool "ansible-lint" "ansible-lint"
install_pipx_tool "yamllint" "yamllint"

# Ansible a plusieurs exécutables provenant de ses dépendances
if command -v ansible-playbook >/dev/null 2>&1; then

    echo "[OK] Ansible déjà installé"

else

    echo "[+] Installation de Ansible"
    pipx install --include-deps ansible

fi

# TFLint

echo
echo "=== TFLint ==="

if command -v tflint >/dev/null 2>&1; then

    echo "[OK] TFLint déjà installé"

else

    TMP_DIR=$(mktemp -d)

    curl -fsSL \
        "https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_${TFLINT_ARCH}.zip" \
        -o "$TMP_DIR/tflint.zip"

    curl -fsSL \
        "https://github.com/terraform-linters/tflint/releases/latest/download/checksums.txt" \
        -o "$TMP_DIR/checksums.txt"

    (
        cd "$TMP_DIR"

        grep "tflint_linux_${TFLINT_ARCH}.zip" checksums.txt |
            sha256sum -c -

        unzip -q tflint.zip
    )

    $SUDO install -m 0755 "$TMP_DIR/tflint" /usr/local/bin/tflint

    rm -rf "$TMP_DIR"

    echo "[OK] TFLint installé"

fi

# tfsec

echo
echo "=== tfsec ==="

if command -v tfsec >/dev/null 2>&1; then

    echo "[OK] tfsec déjà installé"

else

    TMP_FILE=$(mktemp)

    TFSEC_URL=$(
        curl -fsSL \
            https://api.github.com/repos/aquasecurity/tfsec/releases/latest |
            jq -r \
                --arg pattern "tfsec-linux-${TFSEC_ARCH}$" \
                '.assets[]
                | select(.name | test($pattern))
                | .browser_download_url' |
            head -n 1
    )

    if [ -z "$TFSEC_URL" ] || [ "$TFSEC_URL" = "null" ]; then
        echo "[ERREUR] Impossible de trouver le binaire tfsec."
        exit 1
    fi

    curl -fsSL "$TFSEC_URL" -o "$TMP_FILE"

    $SUDO install -m 0755 "$TMP_FILE" /usr/local/bin/tfsec

    rm -f "$TMP_FILE"

    echo "[OK] tfsec installé"

fi

# Gitleaks

echo
echo "=== Gitleaks ==="

if command -v gitleaks >/dev/null 2>&1; then

    echo "[OK] Gitleaks déjà installé"

else

    TMP_DIR=$(mktemp -d)

    GITLEAKS_URL=$(
        curl -fsSL \
            https://api.github.com/repos/gitleaks/gitleaks/releases/latest |
            jq -r \
                --arg pattern "linux_${GITLEAKS_ARCH}\\.tar\\.gz$" \
                '.assets[]
                | select(.name | test($pattern))
                | .browser_download_url' |
            head -n 1
    )

    if [ -z "$GITLEAKS_URL" ] || [ "$GITLEAKS_URL" = "null" ]; then
        echo "[ERREUR] Impossible de trouver Gitleaks."
        exit 1
    fi

    curl -fsSL "$GITLEAKS_URL" -o "$TMP_DIR/gitleaks.tar.gz"

    tar -xzf "$TMP_DIR/gitleaks.tar.gz" -C "$TMP_DIR"

    $SUDO install -m 0755 \
        "$TMP_DIR/gitleaks" \
        /usr/local/bin/gitleaks

    rm -rf "$TMP_DIR"

    echo "[OK] Gitleaks installé"

fi

# Checkmake

echo
echo "=== Checkmake ==="

if command -v checkmake >/dev/null 2>&1; then

    echo "[OK] Checkmake déjà installé"

else

    go install github.com/mrtazz/checkmake/cmd/checkmake@latest

    $SUDO install -m 0755 \
        "$(go env GOPATH)/bin/checkmake" \
        /usr/local/bin/checkmake

    echo "[OK] Checkmake installé"

fi

# Docker

echo
echo "=== Docker ==="

$SUDO systemctl enable --now docker

if getent group docker >/dev/null 2>&1; then

    if ! id -nG "$USER" | grep -qw docker; then

        $SUDO usermod -aG docker "$USER"

        echo "[INFO] $USER ajouté au groupe docker."
        echo "[INFO] Une reconnexion sera nécessaire pour utiliser Docker sans sudo."

    fi

fi

# Vérification finale

echo
echo "======================================"
echo " Vérification des installations"
echo "======================================"

TOOLS=(
    git
    make
    terraform
    az
    pre-commit
    tflint
    tfsec
    checkov
    gitleaks
    trivy
    ansible-playbook
    ansible-lint
    yamllint
    checkmake
    docker
    shellcheck
    gh
)

ERRORS=0

for TOOL in "${TOOLS[@]}"; do

    if command -v "$TOOL" >/dev/null 2>&1; then
        printf "[OK]      %-20s %s\n" "$TOOL" "$(command -v "$TOOL")"
    else
        printf "[MANQUANT] %-20s\n" "$TOOL"
        ERRORS=$((ERRORS + 1))
    fi

done

echo
echo "======================================"

if [ "$ERRORS" -eq 0 ]; then

    echo " Tous les outils sont installés."

else

    echo " $ERRORS outil(s) manquant(s)."
    exit 1

fi
