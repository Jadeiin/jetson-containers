#!/usr/bin/env bash
set -e

# Install OpenCV from apt package
echo "Installing OpenCV from nvidia-opencv-dev package..."
apt-get update
apt-get install -y nvidia-opencv-dev
rm -rf /var/lib/apt/lists/*
apt-get clean