#!/usr/bin/env pwsh
# File: ./setup.ps1
# Purpose: Cross-platform initialization of project structure

# Function to ensure directory is empty and has correct permissions
function Initialize-Directory {
    param (
        [string]$Path
    )
    
    # Convert to platform-specific path
    $Path = $Path -replace '[\\/]', [IO.Path]::DirectorySeparatorChar
    
    # Create or clean directory
    if (Test-Path $Path) {
        Get-ChildItem -Path $Path -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        $null = New-Item -ItemType Directory -Force -Path $Path
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

# Create and initialize base directories
$directories = @(
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
    "searxng",
    "nginx/data",
    "nginx/letsencrypt",
    "node-red/data"
)

# Initialize all directories
foreach ($dir in $directories) {
    Initialize-Directory -Path $dir
}

# Clone Perplexica repository
Write-Host "Cloning Perplexica repository..."
if (Test-Path "perplexica") {
    Remove-Item -Recurse -Force "perplexica"
}
git clone https://github.com/ItzCrazyKns/Perplexica.git perplexica
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error cloning Perplexica repository"
    exit 1
}

# Copy sample config to config.toml
Copy-Item "perplexica/sample.config.toml" "config.toml" -Force
Write-Host "Copied sample.config.toml to config.toml"

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
    "node-red/data/.gitkeep"
)

foreach ($file in $placeholders) {
    $file = $file -replace '[\\/]', [IO.Path]::DirectorySeparatorChar
    if (-not (Test-Path $file)) {
        $null = New-Item -ItemType File -Force -Path $file
        Write-Host "Created placeholder: $file"
    }
}

# Create MongoDB initialization script
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

# Update config.toml with Ollama settings
$configContent = Get-Content "config.toml" -Raw
$configContent = $configContent -replace 'OLLAMA = ""', 'OLLAMA = "http://ollama:11434"'
$configContent | Set-Content "config.toml" -NoNewline
Write-Host "Updated config.toml with Ollama settings"

Write-Host "`nSetup complete! Please ensure you have:"
Write-Host "1. Updated the .env file with your specific settings"
Write-Host "2. Added any required API keys to config.toml"
Write-Host "`nTo start the services, run: docker compose --profile cpu up -d"
