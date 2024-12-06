# File: ./setup.ps1
# Purpose: Initialize the project structure and required directories for Windows

# Create base directories
$directories = @(
    "n8n\backup\workflows",
    "n8n\backup\credentials",
    "shared",
    ".devcontainer",
    "flowise\data",    # Added Flowise directory with data subdirectory
    "flowise\storage"  # Added storage directory for Flowise persistence
)

# Create all directories
foreach ($dir in $directories) {
    New-Item -ItemType Directory -Force -Path $dir
    Write-Host "Created directory: $dir"
}

# Create placeholder files
$placeholders = @(
    "n8n\backup\workflows\.gitkeep",
    "n8n\backup\credentials\.gitkeep",
    "shared\.gitkeep",
    "flowise\data\.gitkeep",
    "flowise\storage\.gitkeep"
)

foreach ($file in $placeholders) {
    New-Item -ItemType File -Force -Path $file
    Write-Host "Created placeholder: $file"
}

# Create .env file if it doesn't exist
if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "Please update the .env file with your specific settings"
}

Write-Host "Setup complete! Please ensure you have updated the .env file with your specific settings."