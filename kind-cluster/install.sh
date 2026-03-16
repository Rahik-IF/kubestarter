#!/usr/bin/env bash

set -e
set -o pipefail

echo "🚀 Installing Docker, Kind, and kubectl..."

# -------------------------------------------------
# Detect OS
# -------------------------------------------------
OS=$(uname | tr '[:upper:]' '[:lower:]')

# -------------------------------------------------
# Detect Architecture
# -------------------------------------------------
ARCH=$(uname -m)

if [[ "$ARCH" == "x86_64" ]]; then
    ARCH="amd64"
elif [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
    ARCH="arm64"
else
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
fi

echo "🖥 OS: $OS"
echo "⚙️ Architecture: $ARCH"

# -------------------------------------------------
# Install Docker (Linux only)
# -------------------------------------------------
if [[ "$OS" == "linux" ]]; then
    if ! command -v docker &>/dev/null; then
        echo "📦 Installing Docker..."

        sudo apt-get update -y
        sudo apt-get install -y docker.io

        sudo systemctl enable docker
        sudo systemctl start docker

        sudo usermod -aG docker "$USER"

        echo "✅ Docker installed."
        echo "⚠️ You may need to logout/login for docker group changes."
    else
        echo "✅ Docker already installed."
    fi
else
    echo "ℹ️ macOS detected."
    echo "⚠️ Please install Docker Desktop manually:"
    echo "https://www.docker.com/products/docker-desktop"
fi

# -------------------------------------------------
# Install Kind
# -------------------------------------------------
if ! command -v kind &>/dev/null; then
    echo "📦 Installing Kind..."

    KIND_VERSION="v0.29.0"

    curl -Lo ./kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-${OS}-${ARCH}"

    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind

    echo "✅ Kind installed."
else
    echo "✅ Kind already installed."
fi

# -------------------------------------------------
# Install kubectl
# -------------------------------------------------
if ! command -v kubectl &>/dev/null; then
    echo "📦 Installing kubectl..."

    VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)

    curl -Lo kubectl "https://dl.k8s.io/release/${VERSION}/bin/${OS}/${ARCH}/kubectl"

    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/kubectl

    echo "✅ kubectl installed."
else
    echo "✅ kubectl already installed."
fi

# -------------------------------------------------
# Verify installation
# -------------------------------------------------
echo
echo "🔎 Installed versions"

if command -v docker &>/dev/null; then
    docker --version
fi

kind --version
kubectl version --client

echo
echo "🎉 Installation complete!"