#!/bin/bash

# failsafe
set -e

SOURCE_DIR="/run/media/kane/Storage/projects/homelab/nix/"
TARGET_DIR="/home/kane/nix_conf"
SSH_KEY="/home/kane/.secrets/keys/pi_server_ssh_PRIVATE_KEY"
REMOTE_USER="kane"
REMOTE_HOST="192.168.0.228"

SSH_CMD="ssh -i $SSH_KEY"

REMOTE_TARGET="${REMOTE_USER}@${REMOTE_HOST}:${TARGET_DIR}"

echo "Sending Nix config to server..."
echo "  Source: $SOURCE_DIR"
echo "  Target: $REMOTE_TARGET"

# a - archive
# v - verbose
# e - remote shell
rsync -av -e "$SSH_CMD" "$SOURCE_DIR" "$REMOTE_TARGET"

echo "Complete"