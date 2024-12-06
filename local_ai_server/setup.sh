#!/bin/bash
# File: ./setup.sh
# Purpose: Initialize the project structure and required directories

# Create necessary directories
mkdir -p n8n/backup/workflows
mkdir -p n8n/backup/credentials
mkdir -p shared

# Set up proper permissions
chmod 777 shared
chmod -R 777 n8n/backup

# Create placeholders to ensure directories are tracked
touch n8n/backup/workflows/.gitkeep
touch n8n/backup/credentials/.gitkeep
touch shared/.gitkeep

# Add environment file if it doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Please update the .env file with your specific settings"
fi

echo "Setup complete! Please ensure you have updated the .env file with your specific settings."