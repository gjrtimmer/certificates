#!/usr/bin/env bash
# shellcheck shell=bash disable=SC2034

SCRIPT_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
DEVCON_DIR="$(dirname "${SCRIPT_DIR}")"
CONFIG_DIR="${DEVCON_DIR}/config"
PROJECT_DIR="$(git rev-parse --show-toplevel)"

printf "\n%s" "Configuring DevContainer..."

# shellcheck disable=SC2154
git -C "${PROJECT_DIR}" config --global --add safe.directory /work
git -C "${PROJECT_DIR}" config core.autocrlf false
git -C "${PROJECT_DIR}" config core.eol lf

# Configure Ansible Vault Pass
sudo chmod -x "${HOME}/.ansible_vault_pass"

# Configure ownership mounts
sudo chmod 0644 "${HOME}/.ssh/config"
sudo chmod 0644 "${HOME}/.ssh/known_hosts"
sudo chmod 0755 "${HOME}/.ssh/tpi"
sudo chmod 0600 "${HOME}/.ssh/tpi/*.key"
sudo chmod 0755 "${HOME}/.ssh/tpi/*.key.pub"
sudo chown -R vscode:vscode "${HOME}/.ssh/tpi"

if [[ ! -f "${DEVCON_DIR}/.bashrc" ]]; then
    ln -sf "${DEVCON_DIR}/.bashrc" "${HOME}/.bashrc"
fi

# Finalizing DevContainer
printf "%s\n" "[DONE]"

# Install collections
printf "\n%s\n" "Running Ansible Galaxy"
ANSIBLE_COLLECTIONS_PATH=/work/.ansible/collections ansible-galaxy collection install -U -p .ansible/collections -r requirements.yml
ANSIBLE_ROLES_PATH=/work/.ansible/roles ansible-galaxy role install -p .ansible/roles -r requirements.yml

printf "\n%s\n\n" "Container Start Completed"
