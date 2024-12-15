#!/usr/bin/env pwsh
# File: ./perplexica/perplexica.ps1
# Purpose: Setup and configuration for Perplexica

param (
    [string]$Command = "setup"
)

function Setup {
    Write-Host "Setting up Perplexica..." -ForegroundColor Cyan

    # Clone Perplexica repository if it doesn't exist
    if (-not (Test-Path -Path ".\perplexica")) {
        Write-Host "Cloning Perplexica repository..."
        git clone https://github.com/ItzCrazyKns/Perplexica.git perplexica
    }

    # Copy and configure config.toml
    Write-Host "Configuring Perplexica..."
    Copy-Item -Path ".\perplexica\sample.config.toml" -Destination ".\perplexica\config.toml"

    # Configure to use existing services
    $config = Get-Content ".\perplexica\config.toml" -Raw
    $config = $config -replace 'SEARXNG = ""', 'SEARXNG = "http://host.docker.internal:4000"'
    $config = $config -replace 'OLLAMA = ""', 'OLLAMA = "http://host.docker.internal:11434"'
    Set-Content ".\perplexica\config.toml" -Value $config

    # Navigate to Perplexica directory
    Push-Location -Path ".\perplexica"

    # Modify docker-compose.yaml to remove searxng service
    Write-Host "Updating docker-compose configuration..."
    $compose = Get-Content "docker-compose.yaml" -Raw
    $compose = $compose -replace '(?ms) searxng:.*? volumes:.*?\n\n', ''
    Set-Content "docker-compose.yaml" -Value $compose

    # Return to original directory
    Pop-Location

    Write-Host "Perplexica setup complete!" -ForegroundColor Green
    Write-Host "You can access Perplexica at http://localhost:3000 after starting the services" -ForegroundColor Yellow
    Write-Host "Note: Make sure to select 'llama2' as your model in the Perplexica settings" -ForegroundColor Yellow
}

# Execute the specified command
switch ($Command.ToLower()) {
    "setup" {
        Setup
    }
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Write-Host "Available commands: setup" -ForegroundColor Yellow
    }
}
