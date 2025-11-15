#!/bin/bash

# failsafe
set -e

SOURCE_DIR="/mnt/NAS/Data/Obsidian/Homelab/"
TARGET_DIR="/run/media/kane/Storage/projects/homelab/documentation/"

echo "Syncronizing documentation..."
echo "  Source: $SOURCE_DIR"
echo "  Target: $TARGET_DIR"

# a - archive
# v - verbose 
# --delete - mirror copy of files
# n - dry run

rsync -av --delete "$SOURCE_DIR" "$TARGET_DIR"

echo "Complete"