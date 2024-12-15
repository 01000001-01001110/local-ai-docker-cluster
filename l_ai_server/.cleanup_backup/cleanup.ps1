#!/usr/bin/env pwsh
# File: ./cleanup.ps1
# Purpose: Clean up project directories and service-specific components while preserving core files

Write-Host "Starting cleanup process..." -ForegroundColor Cyan

# Files that should NEVER be deleted (core project files)
$preserveFiles = @(
    # Core configuration
    ".env",
    ".env.example",
    ".gitignore",
    "cleanup.ps1",
    "comfyui.dockerfile",
    "config.toml",
    "docker-compose.yml",
    "README.md",
    "setup.ps1",
    "switch-mode.ps1",

    # Service-specific scripts and their READMEs
    "perplexica/perplexica.ps1",
    "comfyui/comfyui.ps1",
    "searxng/searxng.ps1",
    "node-red/node-red.ps1",
    "flowise/flowise.ps1",
    "n8n/n8n.ps1",
    "mongodb/mongodb.ps1",
    "postgres/postgres.ps1",
    "nginx/nginx.ps1",
    "open-webui/open-webui.ps1",
    "ollama/ollama.ps1",
    "qdrant/qdrant.ps1",
    "perplexica/README.md",
    "comfyui/README.md",
    "searxng/README.md",
    "node-red/README.md",
    "flowise/README.md",
    "n8n/README.md",
    "mongodb/README.md",
    "postgres/README.md",
    "nginx/README.md",
    "open-webui/README.md",
    "ollama/README.md",
    "qdrant/README.md"
)

Write-Host "`nBacking up core files..." -ForegroundColor Cyan
$backupDir = ".cleanup_backup"
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
}

# Backup core files
foreach ($file in $preserveFiles) {
    if (Test-Path $file) {
        # Create subdirectories in backup if needed
        $destDir = Split-Path -Parent (Join-Path $backupDir $file)
        if ($destDir -and -not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        }
        Copy-Item $file (Join-Path $backupDir $file) -Force
        Write-Host "Backed up: $file"
    }
}

Write-Host "`nRemoving repository directories..." -ForegroundColor Cyan
# Remove l_ai_server directories
Get-ChildItem -Path "." -Directory -Recurse | Where-Object { $_.Name -eq "l_ai_server" } | ForEach-Object {
    Remove-Item -Recurse -Force $_.FullName
    Write-Host "Removed directory: $($_.FullName)"
}

# Remove repo directories
Get-ChildItem -Path "." -Directory -Recurse | Where-Object { $_.Name -eq "repo" } | ForEach-Object {
    Remove-Item -Recurse -Force $_.FullName
    Write-Host "Removed directory: $($_.FullName)"
}

# Directories that should be cleaned (only data and generated content)
$dataDirectories = @(
    # Service data directories
    "n8n/backup/workflows",
    "n8n/backup/credentials",
    "n8n/data",
    "shared",
    ".devcontainer",
    "flowise/data",
    "flowise/storage",
    "mongodb/data",
    "mongodb/init",
    "postgres/data/pgdata",
    "qdrant/storage",
    "ollama/models",
    "open-webui/data",
    "searxng/data",
    "nginx/data",
    "nginx/letsencrypt",
    "node-red/data",
    
    # ComfyUI data
    "volumes/comfyui/models/checkpoints",
    "volumes/comfyui/models/clip",
    "volumes/comfyui/models/controlnet",
    "volumes/comfyui/models/embeddings",
    "volumes/comfyui/models/loras",
    "volumes/comfyui/models/upscale_models",
    "volumes/comfyui/models/vae",
    "volumes/comfyui/models/unet",
    "comfyui/input",
    "comfyui/output",
    "comfyui/custom_nodes",
    
    # Perplexica data
    "volumes/perplexica/data",
    "volumes/perplexica/uploads"
)

Write-Host "`nCleaning data directories..." -ForegroundColor Cyan

# Function to safely clean a directory while preserving .gitkeep
function Clear-Directory {
    param (
        [string]$Path
    )
    
    if (Test-Path $Path) {
        # Remove all contents except .gitkeep
        Get-ChildItem -Path $Path -Exclude ".gitkeep" | Remove-Item -Recurse -Force
        # Create .gitkeep if it doesn't exist
        if (-not (Test-Path "$Path/.gitkeep")) {
            $null = New-Item -ItemType File -Path "$Path/.gitkeep" -Force
        }
        Write-Host "Cleaned directory: $Path"
    } else {
        # Create directory if it doesn't exist
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
        $null = New-Item -ItemType File -Path "$Path/.gitkeep" -Force
        Write-Host "Created directory: $Path"
    }
}

# Clean all data directories
foreach ($dir in $dataDirectories) {
    Clear-Directory -Path $dir
}

# Clean up service-specific components
Write-Host "`nCleaning up service-specific components..." -ForegroundColor Cyan

# Define service cleanup scripts
$serviceScripts = @(
    "perplexica/perplexica.ps1",
    "comfyui/comfyui.ps1",
    "searxng/searxng.ps1",
    "node-red/node-red.ps1",
    "flowise/flowise.ps1",
    "n8n/n8n.ps1",
    "mongodb/mongodb.ps1",
    "postgres/postgres.ps1",
    "nginx/nginx.ps1",
    "open-webui/open-webui.ps1",
    "ollama/ollama.ps1",
    "qdrant/qdrant.ps1"
)

# Execute each service cleanup script
foreach ($script in $serviceScripts) {
    if (Test-Path $script) {
        Write-Host "`nCleaning up $($script.Split('/')[0])..." -ForegroundColor Cyan
        
        # Get the directory of the script
        $scriptDir = Split-Path -Parent $script
        $scriptName = Split-Path -Leaf $script
        
        # Execute the script in its directory
        Push-Location $scriptDir
        & "./$scriptName" cleanup
        Pop-Location
    }
}

# Restore core files
Write-Host "`nRestoring core files..." -ForegroundColor Cyan
Get-ChildItem -Path $backupDir -Recurse -File | ForEach-Object {
    $relativePath = $_.FullName.Substring($backupDir.Length + 1)
    
    # Ensure destination directory exists
    $destDir = Split-Path -Parent $relativePath
    if ($destDir -and -not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    }
    
    Copy-Item $_.FullName $relativePath -Force
    Write-Host "Restored: $relativePath"
}

# Remove backup directory
Remove-Item -Recurse -Force $backupDir
Write-Host "Removed backup directory"

Write-Host "`nCleanup complete!" -ForegroundColor Green
Write-Host "Core project files have been preserved. Data directories have been cleaned." -ForegroundColor White
Write-Host "You can now run setup.ps1 to reinitialize the data directories." -ForegroundColor White

# List preserved files
Write-Host "`nPreserved core files:" -ForegroundColor Cyan
foreach ($file in $preserveFiles) {
    if (Test-Path $file) {
        Write-Host "- $file"
    }
}
