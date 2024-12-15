#!/usr/bin/env pwsh
# File: ./open-webui/open-webui.ps1
# Purpose: Handle Open WebUI setup and configuration

param(
    [Parameter(Position=0)]
    [string]$Action = "setup"
)

function Initialize-OpenWebUI {
    Write-Host "`nInitializing Open WebUI..." -ForegroundColor Cyan
    
    # Create necessary directories if they don't exist
    $directories = @(
        ".",  # Ensure open-webui directory exists
        "./data"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Force -Path $dir
            Write-Host "Created directory: $dir"
        }
    }

    # Create default configuration without BOM
    Write-Host "Creating default configuration..." -ForegroundColor Cyan
    $config = @{
        theme = @{
            name = "default"
            mode = "dark"
        }
        models = @{
            default = "tinyllama"
            available = @(
                "tinyllama",
                "mistral-7b",
                "codellama-7b",
                "nomic-embed-text"
            )
        }
        interface = @{
            show_system_prompt = $true
            show_model_name = $true
            show_timestamps = $true
            show_copy_button = $true
            enable_chat_history = $true
            enable_code_highlighting = $true
            enable_latex_rendering = $true
        }
        chat = @{
            max_history_length = 100
            temperature = 0.7
            top_p = 0.9
            top_k = 40
            repeat_penalty = 1.1
            max_new_tokens = 2048
        }
        system = @{
            enable_telemetry = $false
            auto_update = $true
            gpu_layers = -1
        }
    }

    # Convert to JSON and write without BOM
    $jsonConfig = $config | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText(
        (Join-Path (Get-Location) "data/config.json"),
        $jsonConfig,
        [System.Text.UTF8Encoding]::new($false)
    )
    Write-Host "Created config.json"

    # Create README
    @"
# Open WebUI Configuration

This directory contains Open WebUI configuration and data files.

## Directory Structure

- data/
  - config.json: Main configuration file
  - chat_history/: User chat histories
  - models/: Model-specific settings

## Configuration

### Theme Settings
- Default and dark mode support
- Customizable interface elements

### Model Configuration
Default models supported:
- tinyllama (1.1B parameters)
- mistral-7b
- codellama-7b
- nomic-embed-text

### Interface Options
- System prompt visibility
- Model name display
- Timestamps
- Copy buttons
- Chat history
- Code highlighting
- LaTeX rendering

### Chat Settings
- History length
- Temperature
- Top-p sampling
- Top-k sampling
- Repeat penalty
- Maximum tokens

## Integration with Ollama

The WebUI connects to Ollama for:
- Model management
- Inference requests
- Embeddings generation

## Usage Guide

1. Access the interface at http://localhost:3003
2. Start with tinyllama model (lightweight)
3. Configure chat parameters
4. Start chatting!

## Model Management

### Adding New Models
1. Pull models through Ollama
2. Add model names to config.json
3. Restart the service

### Model Parameters
Customize per-model settings:
- Context length
- Temperature
- Top-p/Top-k
- Repeat penalty

## Security Notes

1. No authentication by default
2. Use Nginx Proxy Manager for access control
3. Monitor resource usage
4. Regular backups recommended

## Troubleshooting

1. Check logs:
   ```bash
   docker logs lai-open-webui
   ```

2. Common issues:
   - Model loading failures
   - Memory constraints
   - GPU access problems
   - Network connectivity

3. Performance:
   - Adjust GPU layers
   - Monitor memory usage
   - Check model loading times

## Backup and Restore

Important files to backup:
- config.json
- Chat histories
- Custom model settings

## Best Practices

1. Regular configuration backups
2. Monitor resource usage
3. Update models regularly
4. Test new models before production
5. Keep chat histories manageable
6. Use appropriate model parameters
"@ | Out-File -FilePath "README.md" -Encoding UTF8 -NoNewline
    Write-Host "Created README.md"

    Write-Host "Open WebUI initialization complete!" -ForegroundColor Green
    return $true
}

function Cleanup-OpenWebUI {
    Write-Host "`nCleaning up Open WebUI..." -ForegroundColor Cyan
    
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

    # Clean data directory but preserve script and README
    Clear-Directory -Path "data"

    # Recreate configuration
    Write-Host "Recreating Open WebUI configuration..." -ForegroundColor Cyan
    Initialize-OpenWebUI | Out-Null

    Write-Host "Open WebUI cleanup complete!" -ForegroundColor Green
}

# Execute the appropriate action
switch ($Action.ToLower()) {
    "setup" {
        Initialize-OpenWebUI
    }
    "cleanup" {
        Cleanup-OpenWebUI
    }
    default {
        Write-Host "Invalid action. Use 'setup' or 'cleanup'" -ForegroundColor Red
    }
}
