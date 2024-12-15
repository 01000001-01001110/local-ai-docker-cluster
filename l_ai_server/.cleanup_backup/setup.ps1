#!/usr/bin/env pwsh
# File: ./setup.ps1
# Purpose: Cross-platform initialization of project structure

# Check if Docker Desktop is running
Write-Host "Checking Docker Desktop status..." -ForegroundColor Cyan
try {
    $dockerStatus = docker info 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`nError: Docker Desktop is not running!" -ForegroundColor Red
        Write-Host "Please:" -ForegroundColor Yellow
        Write-Host "1. Open Docker Desktop" -ForegroundColor Yellow
        Write-Host "2. Wait for it to fully start (check the whale icon in system tray)" -ForegroundColor Yellow
        Write-Host "3. Run this script again" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "`nError: Docker Desktop is not installed or not in PATH!" -ForegroundColor Red
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Install Docker Desktop from https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    Write-Host "2. Start Docker Desktop" -ForegroundColor Yellow
    Write-Host "3. Run this script again" -ForegroundColor Yellow
    exit 1
}

Write-Host "Docker Desktop is running" -ForegroundColor Green

# Function to ensure directory is empty and has correct permissions
function Initialize-Directory {
    param (
        [string]$Path,
        [switch]$KeepContents,
        [switch]$Clean
    )
    
    # Convert to platform-specific path
    $Path = $Path -replace '[\\/]', [IO.Path]::DirectorySeparatorChar
    
    # Create directory if it doesn't exist
    if (-not (Test-Path $Path)) {
        $null = New-Item -ItemType Directory -Force -Path $Path
    } elseif ($Clean) {
        # Clean directory but preserve .ps1 and README.md files
        Get-ChildItem -Path $Path | Where-Object { 
            -not ($_.Name -match '\.ps1$' -or $_.Name -eq 'README.md')
        } | Remove-Item -Recurse -Force
    }
    
    # Set permissions based on OS
    if ($IsWindows) {
        $acl = Get-Acl $Path
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            [System.Security.Principal.WindowsIdentity]::GetCurrent().Name,
            "FullControl",
            "ContainerInherit,ObjectInherit",
            "None",
            "Allow"
        )
        $acl.SetAccessRule($accessRule)
        Set-Acl $Path $acl
    } elseif ($IsLinux -or $IsMacOS) {
        # Only use chmod on Unix-like systems
        & chmod 755 $Path
    }
    
    Write-Host "Initialized directory: $Path"
}

# Remove any existing l_ai_server directories
Write-Host "`nCleaning up any existing repository directories..." -ForegroundColor Cyan
Get-ChildItem -Path "." -Directory -Recurse -Include "l_ai_server", "repo" | ForEach-Object {
    Remove-Item -Recurse -Force $_.FullName
    Write-Host "Removed directory: $($_.FullName)"
}

# Create and initialize base directories
$directories = @(
    # Service directories (preserve scripts)
    @{Path="perplexica"; Keep=$true; Clean=$true},
    @{Path="comfyui"; Keep=$true; Clean=$true},
    @{Path="searxng"; Keep=$true; Clean=$true},
    @{Path="node-red"; Keep=$true; Clean=$true},
    @{Path="flowise"; Keep=$true; Clean=$true},
    @{Path="n8n"; Keep=$true; Clean=$true},
    @{Path="mongodb"; Keep=$true; Clean=$true},
    @{Path="postgres"; Keep=$true; Clean=$true},
    @{Path="nginx"; Keep=$true; Clean=$true},
    @{Path="open-webui"; Keep=$true; Clean=$true},
    @{Path="ollama"; Keep=$true; Clean=$true},
    @{Path="qdrant"; Keep=$true; Clean=$true},

    # Data directories (clean)
    @{Path="n8n/backup/workflows"; Keep=$false; Clean=$true},
    @{Path="n8n/backup/credentials"; Keep=$false; Clean=$true},
    @{Path="n8n/data"; Keep=$false; Clean=$true},
    @{Path="shared"; Keep=$false; Clean=$true},
    @{Path=".devcontainer"; Keep=$false; Clean=$true},
    @{Path="flowise/data"; Keep=$false; Clean=$true},
    @{Path="flowise/storage"; Keep=$false; Clean=$true},
    @{Path="mongodb/data"; Keep=$false; Clean=$true},
    @{Path="mongodb/init"; Keep=$false; Clean=$true},
    @{Path="postgres/data/pgdata"; Keep=$false; Clean=$true},
    @{Path="qdrant/storage"; Keep=$false; Clean=$true},
    @{Path="ollama/models"; Keep=$false; Clean=$true},
    @{Path="open-webui/data"; Keep=$false; Clean=$true},
    @{Path="searxng/data"; Keep=$false; Clean=$true},
    @{Path="nginx/data"; Keep=$false; Clean=$true},
    @{Path="nginx/letsencrypt"; Keep=$false; Clean=$true},
    @{Path="node-red/data"; Keep=$false; Clean=$true},
    
    # ComfyUI directories
    @{Path="volumes/comfyui/models/checkpoints"; Keep=$false; Clean=$true},
    @{Path="volumes/comfyui/models/clip"; Keep=$false; Clean=$true},
    @{Path="volumes/comfyui/models/controlnet"; Keep=$false; Clean=$true},
    @{Path="volumes/comfyui/models/embeddings"; Keep=$false; Clean=$true},
    @{Path="volumes/comfyui/models/loras"; Keep=$false; Clean=$true},
    @{Path="volumes/comfyui/models/upscale_models"; Keep=$false; Clean=$true},
    @{Path="volumes/comfyui/models/vae"; Keep=$false; Clean=$true},
    @{Path="volumes/comfyui/models/unet"; Keep=$false; Clean=$true},
    @{Path="comfyui/input"; Keep=$false; Clean=$true},
    @{Path="comfyui/output"; Keep=$false; Clean=$true},
    @{Path="comfyui/custom_nodes"; Keep=$false; Clean=$true},
    
    # Perplexica directories
    @{Path="volumes/perplexica/data"; Keep=$false; Clean=$true},
    @{Path="volumes/perplexica/uploads"; Keep=$false; Clean=$true}
)

Write-Host "`nCreating directories..." -ForegroundColor Cyan

# Initialize all directories
foreach ($dir in $directories) {
    Initialize-Directory -Path $dir.Path -KeepContents:$dir.Keep -Clean:$dir.Clean
}

# Create placeholder files
$placeholders = @(
    "n8n/backup/workflows/.gitkeep",
    "n8n/backup/credentials/.gitkeep",
    "n8n/data/.gitkeep",
    "shared/.gitkeep",
    "flowise/data/.gitkeep",
    "flowise/storage/.gitkeep",
    "mongodb/data/.gitkeep",
    "qdrant/storage/.gitkeep",
    "ollama/models/.gitkeep",
    "open-webui/data/.gitkeep",
    "nginx/data/.gitkeep",
    "nginx/letsencrypt/.gitkeep",
    "node-red/data/.gitkeep",
    # ComfyUI placeholders
    "volumes/comfyui/models/checkpoints/.gitkeep",
    "volumes/comfyui/models/clip/.gitkeep",
    "volumes/comfyui/models/controlnet/.gitkeep",
    "volumes/comfyui/models/embeddings/.gitkeep",
    "volumes/comfyui/models/loras/.gitkeep",
    "volumes/comfyui/models/upscale_models/.gitkeep",
    "volumes/comfyui/models/vae/.gitkeep",
    "volumes/comfyui/models/unet/.gitkeep",
    "comfyui/input/.gitkeep",
    "comfyui/output/.gitkeep",
    "comfyui/custom_nodes/.gitkeep",
    # Perplexica placeholders
    "volumes/perplexica/data/.gitkeep",
    "volumes/perplexica/uploads/.gitkeep"
)

Write-Host "`nCreating placeholder files..." -ForegroundColor Cyan

foreach ($file in $placeholders) {
    $file = $file -replace '[\\/]', [IO.Path]::DirectorySeparatorChar
    if (-not (Test-Path $file)) {
        $null = New-Item -ItemType File -Force -Path $file
        Write-Host "Created placeholder: $file"
    }
}

# Create MongoDB initialization script
Write-Host "`nCreating MongoDB initialization script..." -ForegroundColor Cyan

$mongoInitScript = @"
print('Starting MongoDB initialization...');

try {
    // Wait for MongoDB to be ready
    sleep(5000);

    // Switch to admin database
    db = db.getSiblingDB('admin');

    // Create root user if it doesn't exist
    if (!db.getUser(process.env.MONGODB_USER)) {
        db.createUser({
            user: process.env.MONGODB_USER,
            pwd: process.env.MONGODB_PASSWORD,
            roles: ['root']
        });
    }

    // Switch to langchain database
    db = db.getSiblingDB(process.env.MONGODB_DATABASE);

    // Create collections if they don't exist
    if (!db.getCollectionNames().includes('vectors')) {
        db.createCollection('vectors');
        print('Created vectors collection');
    }

    // Create vector search index
    db.vectors.createIndex(
        {
            "embedding": {
                "type": "vectorSearch",
                "numDimensions": 1536,
                "similarity": "cosine"
            }
        },
        {
            name: "vector_index"
        }
    );
    print('Created vector search index');

} catch (err) {
    print('Error during initialization: ' + err);
    throw err;
}

print('MongoDB initialization complete');
"@

# Create MongoDB init script with proper path handling
$mongoInitDir = Join-Path -Path "mongodb" -ChildPath "init"
$mongoInitPath = Join-Path -Path $mongoInitDir -ChildPath "init-mongo.js"
$mongoInitScript | Out-File -FilePath $mongoInitPath -Encoding UTF8 -Force
Write-Host "Created MongoDB initialization script"

# Create .env file if it doesn't exist
Write-Host "`nChecking .env file..." -ForegroundColor Cyan
if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "Created .env file from .env.example"
    } else {
        @"
# Database Configuration
POSTGRES_USER=root
POSTGRES_PASSWORD=password
POSTGRES_DB=n8n

# MongoDB Configuration
MONGODB_USER=root
MONGODB_PASSWORD=password
MONGODB_DATABASE=langchain_db

# N8N Security Settings
N8N_ENCRYPTION_KEY=your-encryption-key
N8N_USER_MANAGEMENT_JWT_SECRET=your-jwt-secret

# Optional GPU Settings
NVIDIA_VISIBLE_DEVICES=all
"@ | Out-File -FilePath ".env" -Encoding UTF8
        Write-Host "Created new .env file with default values"
    }
}

# Initialize service-specific components
Write-Host "`nInitializing service-specific components..." -ForegroundColor Cyan

# Define service setup scripts
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

# Execute each service setup script
foreach ($script in $serviceScripts) {
    if (Test-Path $script) {
        Write-Host "`nSetting up $($script.Split('/')[0])..." -ForegroundColor Cyan
        Push-Location (Split-Path -Parent $script)
        & "./$(Split-Path -Leaf $script)" setup
        Pop-Location
    }
}

Write-Host "`nStarting services with GPU support..." -ForegroundColor Cyan
docker compose --profile gpu-nvidia up -d

Write-Host "`nWaiting for services to be ready..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

Write-Host "`nSetting up Perplexica..." -ForegroundColor Cyan

# Clone Perplexica repository if it doesn't exist
if (-not (Test-Path -Path ".\perplexica\Perplexica")) {
    Write-Host "Cloning Perplexica repository..."
    Push-Location -Path ".\perplexica"
    git clone https://github.com/ItzCrazyKns/Perplexica.git
    Pop-Location
}

# Copy and configure config.toml
Write-Host "Configuring Perplexica..."
Copy-Item -Path ".\perplexica\Perplexica\sample.config.toml" -Destination ".\perplexica\Perplexica\config.toml"

# Configure to use existing services
$config = Get-Content ".\perplexica\Perplexica\config.toml" -Raw
$config = $config -replace 'SEARXNG = ""', 'SEARXNG = "http://host.docker.internal:4000"'
$config = $config -replace 'OLLAMA = ""', 'OLLAMA = "http://host.docker.internal:11434"'
Set-Content ".\perplexica\Perplexica\config.toml" -Value $config

# Navigate to Perplexica directory
Push-Location -Path ".\perplexica\Perplexica"

# Modify docker-compose.yaml to remove searxng service
Write-Host "Updating docker-compose configuration..."
$compose = Get-Content "docker-compose.yaml" -Raw
$compose = $compose -replace '(?ms) searxng:.*? volumes:.*?\n\n', ''
Set-Content "docker-compose.yaml" -Value $compose

# Start Perplexica containers
Write-Host "Starting Perplexica containers..."
docker compose up -d

# Return to original directory
Pop-Location

Write-Host "`nSetup complete!" -ForegroundColor Green
Write-Host "You can now access Perplexica at http://localhost:3000" -ForegroundColor Yellow
Write-Host "Note: Make sure to select 'llama2' as your model in the Perplexica settings" -ForegroundColor Yellow
