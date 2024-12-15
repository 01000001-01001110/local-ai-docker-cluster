#!/usr/bin/env pwsh
# File: ./ollama/ollama.ps1
# Purpose: Handle Ollama setup and configuration

param(
    [Parameter(Position=0)]
    [string]$Action = "setup"
)

function Initialize-Ollama {
    Write-Host "`nInitializing Ollama..." -ForegroundColor Cyan
    
    # Create necessary directories if they don't exist
    $directories = @(
        ".",  # Ensure ollama directory exists
        "models"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Force -Path $dir
            Write-Host "Created directory: $dir"
        }
    }

    # Create README
    @"
# Ollama Configuration

This directory contains Ollama setup and configuration.

## Directory Structure

- models/: Model files and Modelfiles
- ollama.ps1: Setup script

## Default Models

Starting with lightweight models to ensure compatibility:

1. tinyllama (1.1B parameters)
   - Lightweight model
   - Good for basic tasks
   - Minimal resource requirements
   - Memory usage: ~2GB

2. nomic-embed-text
   - Text embedding model
   - Used for vector operations
   - Memory usage: ~1GB

## Optional Models (Manual Installation)

After testing system stability with default models, you can add:

1. mistral-7b
   - Mid-size model
   - Better performance
   - Memory usage: ~8GB
   - Command: ollama pull mistral-7b

2. codellama-7b
   - Specialized for code
   - Memory usage: ~8GB
   - Command: ollama pull codellama-7b

3. llama2-13b
   - Larger model
   - Superior performance
   - Memory usage: ~16GB
   - Command: ollama pull llama2

## System Requirements

Minimum:
- RAM: 8GB
- Storage: 10GB
- CPU: 4 cores

Recommended:
- RAM: 16GB+
- Storage: 50GB+
- GPU: 8GB VRAM
- CPU: 8 cores

## Memory Management

### CPU Mode
- Base usage: ~2GB
- Per model overhead:
  - tinyllama: ~2GB
  - 7B models: ~8GB
  - 13B models: ~16GB
  - 70B models: ~40GB

### GPU Mode
- VRAM requirements:
  - tinyllama: ~2GB
  - 7B models: ~8GB
  - 13B models: ~16GB
  - 70B models: ~40GB

## Performance Tips

1. Start with tinyllama
   - Test system stability
   - Monitor resource usage
   - Gradually add larger models

2. Memory Optimization
   - Run one model at a time
   - Clear GPU cache between models
   - Monitor system resources

3. GPU Considerations
   - Check VRAM availability
   - Use appropriate batch sizes
   - Monitor temperature

## Troubleshooting

1. Out of Memory
   - Switch to smaller model
   - Close other applications
   - Check system resources
   - Consider GPU mode

2. Slow Performance
   - Check CPU/GPU usage
   - Monitor memory usage
   - Reduce concurrent operations

3. Model Loading Issues
   - Verify disk space
   - Check network connection
   - Confirm model compatibility

## Best Practices

1. Resource Management
   - Start with small models
   - Monitor system resources
   - Scale gradually

2. Model Selection
   - Match to hardware capabilities
   - Consider use case requirements
   - Test thoroughly

3. Regular Maintenance
   - Clean unused models
   - Update regularly
   - Monitor performance

## Security Notes

1. API Access
   - Local only by default
   - Configure firewall rules
   - Monitor connections

2. Model Safety
   - Verify model sources
   - Check license compliance
   - Monitor usage patterns

## Integration

Works with:
- Open WebUI
- Perplexica
- Custom applications

## Backup

Important files:
- Modelfiles
- Custom configurations
- Model weights (if modified)
"@ | Out-File -FilePath "README.md" -Encoding UTF8 -NoNewline
    Write-Host "Created README.md"

    Write-Host "Ollama initialization complete!" -ForegroundColor Green
    return $true
}

function Cleanup-Ollama {
    Write-Host "`nCleaning up Ollama..." -ForegroundColor Cyan
    
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

    # Clean models directory but preserve script and README
    Clear-Directory -Path "models"

    Write-Host "Ollama cleanup complete!" -ForegroundColor Green
}

# Execute the appropriate action
switch ($Action.ToLower()) {
    "setup" {
        Initialize-Ollama
    }
    "cleanup" {
        Cleanup-Ollama
    }
    default {
        Write-Host "Invalid action. Use 'setup' or 'cleanup'" -ForegroundColor Red
    }
}
