#!/usr/bin/env pwsh
# File: ./cleanup.ps1
# Purpose: Cross-platform cleanup of Docker resources and local directories

Write-Host "Starting cleanup process..." -ForegroundColor Yellow

# Stop and remove all containers from the compose project
Write-Host "Stopping and removing containers..." -ForegroundColor Cyan
docker compose down --remove-orphans
if ($LASTEXITCODE -ne 0) {
    Write-Host "Warning: Error stopping containers, continuing cleanup..." -ForegroundColor Yellow
}

# Remove all project volumes
Write-Host "Removing Docker volumes..." -ForegroundColor Cyan
$volumes = @(
    "lai_n8n_storage",
    "lai_postgres_storage",
    "lai_ollama_storage",
    "lai_qdrant_storage",
    "lai_open-webui",
    "lai_flowise",
    "lai_mongodb_data"
)

foreach ($volume in $volumes) {
    docker volume rm $volume 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Warning: Volume $volume might not exist, continuing cleanup..." -ForegroundColor Yellow
    }
}

# Remove project network
Write-Host "Removing Docker network..." -ForegroundColor Cyan
docker network rm lai_local_ai_server 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Warning: Network might not exist, continuing cleanup..." -ForegroundColor Yellow
}

# Remove project images
Write-Host "Removing Docker images..." -ForegroundColor Cyan
$images = @(
    "mongo:7.0",
    "flowiseai/flowise",
    "ghcr.io/open-webui/open-webui:main",
    "postgres:16-alpine",
    "n8nio/n8n:latest",
    "qdrant/qdrant",
    "ollama/ollama:latest",
    "jc21/nginx-proxy-manager:latest",
    "nodered/node-red:latest",
    "searxng/searxng:latest"
)

foreach ($image in $images) {
    docker rmi $image 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Warning: Image $image might not exist, continuing cleanup..." -ForegroundColor Yellow
    }
}

# Define directories to remove
$directories = @(
    "n8n",
    "shared",
    ".devcontainer",
    "flowise",
    "mongodb",
    "postgres",
    "qdrant",
    "ollama",
    "open-webui",
    "nginx",
    "node-red",
    "searxng"
)

# Remove directories
Write-Host "Removing local directories..." -ForegroundColor Cyan
foreach ($dir in $directories) {
    $dir = $dir -replace '[\\/]', [IO.Path]::DirectorySeparatorChar
    if (Test-Path $dir) {
        Remove-Item -Path $dir -Recurse -Force
        Write-Host "Removed directory: $dir"
    }
}

# Optionally remove .env file
$removeEnv = Read-Host "Do you want to remove the .env file? (y/n)"
if ($removeEnv -eq 'y') {
    if (Test-Path ".env") {
        Remove-Item -Path ".env" -Force
        Write-Host "Removed .env file"
    }
}

# Clean up any unused Docker resources
Write-Host "Cleaning up unused Docker resources..." -ForegroundColor Cyan
docker system prune -f
if ($LASTEXITCODE -ne 0) {
    Write-Host "Warning: Error during Docker system prune, continuing cleanup..." -ForegroundColor Yellow
}

Write-Host "`nCleanup complete!" -ForegroundColor Green
Write-Host "To start fresh, run setup.ps1 to initialize the project structure." -ForegroundColor Green
