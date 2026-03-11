#!/usr/bin/env bash
set -euo pipefail

assert_tool() {
    if ! command -v "$1" &>/dev/null; then
        echo "ERROR: '$1' is not installed or not on PATH. $2" >&2
        exit 1
    fi
}

echo "Checking prerequisites..."
assert_tool docker  "Install Docker: https://docs.docker.com/engine/install"
assert_tool k3d     "Install k3d: https://k3d.io/#installation  (curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash)"
assert_tool kubectl "Install kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux"
assert_tool tofu    "Install OpenTofu: https://opentofu.org/docs/intro/install"

if ! docker info &>/dev/null; then
    echo "ERROR: Docker daemon is not running. Please start it and try again." >&2
    exit 1
fi

echo "All prerequisites found."

cd "$(dirname "$0")/../tofu"

echo "Initialising OpenTofu..."
tofu init

echo "Phase 1: Creating k3d cluster..."
tofu apply -target="terraform_data.k3d_cluster" -target="terraform_data.k3d_ready" -auto-approve

echo "Phase 2: Deploying remaining infrastructure..."
tofu apply -auto-approve

echo ""
echo "Done. PostgREST is available at http://localhost:8080"
echo "  notifications : http://localhost:8080/notifications"
echo ""
read -p "Press Enter to exit..."