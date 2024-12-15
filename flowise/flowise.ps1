#!/usr/bin/env pwsh
# File: ./flowise/flowise.ps1
# Purpose: Handle Flowise setup and configuration

param(
    [Parameter(Position=0)]
    [string]$Action = "setup"
)

function Initialize-Flowise {
    Write-Host "`nInitializing Flowise..." -ForegroundColor Cyan
    
    # Create necessary directories if they don't exist
    $directories = @(
        ".",  # Ensure flowise directory exists
        "data",
        "storage"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Force -Path $dir
            Write-Host "Created directory: $dir"
        }
    }

    # Create default configuration
    Write-Host "Creating default configuration..." -ForegroundColor Cyan
    @"
{
    "chatbots": [],
    "tools": [],
    "apiKeys": [],
    "credentials": {
        "openai": [],
        "anthropic": [],
        "google": [],
        "azure": []
    },
    "settings": {
        "password": "",
        "flowise_token": "",
        "log_level": "info",
        "execution_mode": "sequential",
        "tools_timeout": 30000,
        "max_nodes": 100
    }
}
"@ | Out-File -FilePath "data/config.json" -Encoding UTF8 -NoNewline
    Write-Host "Created config.json"

    # Create README
    @"
# Flowise Configuration

This directory contains Flowise configuration and storage.

## Directory Structure

- data/
  - config.json: Main configuration
  - flows/: Flow definitions
  - logs/: Application logs
- storage/
  - uploads/: Uploaded files
  - cache/: Temporary data

## Configuration

### Main Settings
- Password protection
- API token
- Log level
- Execution mode
- Tool timeouts
- Node limits

### Credentials
Supported providers:
- OpenAI
- Anthropic
- Google
- Azure

## Features

1. Flow Building:
   - Visual editor
   - Node management
   - Flow testing

2. Tool Integration:
   - API connections
   - Custom tools
   - External services

3. Data Management:
   - File uploads
   - Credential storage
   - Flow persistence

## Security

### Authentication
- Optional password
- API token
- Role-based access

### Data Protection
- Encrypted credentials
- Secure storage
- Access logging

## Integration

Flowise integrates with:
- Language models
- Vector databases
- External APIs
- Custom tools

## Development

### Custom Tools
1. Tool definition
2. Implementation
3. Testing
4. Deployment

### Flow Development
- Component testing
- Error handling
- Performance monitoring
- Version control

## Troubleshooting

1. Check logs:
   ```bash
   docker logs lai-flowise
   ```

2. Common issues:
   - Authentication
   - API connectivity
   - Resource limits
   - Flow execution

3. Debug:
   - Enable debug logging
   - Check configurations
   - Monitor resources

## Best Practices

1. Security:
   - Change default settings
   - Regular backups
   - Access control
   - Credential management

2. Development:
   - Test flows thoroughly
   - Document configurations
   - Version control
   - Error handling

3. Operations:
   - Monitor performance
   - Regular maintenance
   - Resource planning
   - Update management

## Resource Management

1. Storage:
   - Regular cleanup
   - Space monitoring
   - Backup strategy

2. Performance:
   - Node limits
   - Execution timeouts
   - Memory usage
   - CPU utilization

## Backup and Recovery

1. Important files:
   - config.json
   - Flow definitions
   - Credentials
   - Custom tools

2. Backup strategy:
   - Regular backups
   - Version control
   - Recovery testing
   - Documentation
"@ | Out-File -FilePath "README.md" -Encoding UTF8 -NoNewline
    Write-Host "Created README.md"

    Write-Host "Flowise initialization complete!" -ForegroundColor Green
    return $true
}

function Cleanup-Flowise {
    Write-Host "`nCleaning up Flowise..." -ForegroundColor Cyan
    
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

    # Clean data directories but preserve script and README
    $dataDirectories = @(
        "data",
        "storage"
    )

    foreach ($dir in $dataDirectories) {
        Clear-Directory -Path $dir
    }

    # Recreate configuration files
    Write-Host "Recreating Flowise configuration..." -ForegroundColor Cyan
    Initialize-Flowise | Out-Null

    Write-Host "Flowise cleanup complete!" -ForegroundColor Green
}

# Execute the appropriate action
switch ($Action.ToLower()) {
    "setup" {
        Initialize-Flowise
    }
    "cleanup" {
        Cleanup-Flowise
    }
    default {
        Write-Host "Invalid action. Use 'setup' or 'cleanup'" -ForegroundColor Red
    }
}
