#!/usr/bin/env pwsh
# File: ./comfyui/comfyui.ps1
# Purpose: Handle ComfyUI setup and configuration

param(
    [Parameter(Position=0)]
    [string]$Action = "setup"
)

function Initialize-ComfyUI {
    Write-Host "`nInitializing ComfyUI..." -ForegroundColor Cyan
    
    # Create necessary directories if they don't exist
    $directories = @(
        ".",  # Ensure comfyui directory exists
        "input",
        "output",
        "custom_nodes",
        "models",  # Local models directory for documentation
        "../volumes/comfyui/models/checkpoints",
        "../volumes/comfyui/models/clip",
        "../volumes/comfyui/models/controlnet",
        "../volumes/comfyui/models/embeddings",
        "../volumes/comfyui/models/loras",
        "../volumes/comfyui/models/upscale_models",
        "../volumes/comfyui/models/vae",
        "../volumes/comfyui/models/unet"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Force -Path $dir
            Write-Host "Created directory: $dir"
        }
    }

    # Clean directory for cloning (preserve script and README)
    Write-Host "Preparing directory for repository..." -ForegroundColor Cyan
    Get-ChildItem -Path "." | Where-Object {
        $_.Name -ne "comfyui.ps1" -and 
        $_.Name -ne "README.md" -and 
        $_.Name -ne ".gitkeep" -and
        $_.Name -ne "input" -and
        $_.Name -ne "output" -and
        $_.Name -ne "custom_nodes" -and
        $_.Name -ne "models"
    } | Remove-Item -Recurse -Force

    # Clone ComfyUI repository
    Write-Host "Cloning ComfyUI repository..." -ForegroundColor Cyan
    try {
        git clone https://github.com/comfyanonymous/ComfyUI.git repo
        Write-Host "Repository cloned successfully"
    } catch {
        Write-Host "Error cloning ComfyUI repository" -ForegroundColor Red
        return $false
    }

    # Set up custom nodes directory
    Write-Host "Setting up custom nodes directory..." -ForegroundColor Cyan
    @"
# ComfyUI Custom Nodes

This directory contains custom nodes for ComfyUI.

## Installation

1. Place custom node directories here
2. Restart ComfyUI
3. New nodes will appear in the interface

## Structure

Each custom node should be in its own directory:
```
custom_nodes/
  ├── node1/
  │   ├── __init__.py
  │   └── node_code.py
  └── node2/
      ├── __init__.py
      └── node_code.py
```

## Development

1. Follow ComfyUI node development guidelines
2. Test thoroughly before deployment
3. Document node functionality
4. Include requirements.txt if needed

## Best Practices

1. Clear documentation
2. Error handling
3. Resource management
4. Version compatibility
"@ | Out-File -FilePath "custom_nodes/README.md" -Encoding UTF8 -NoNewline

    # Create input directory README
    @"
# ComfyUI Input Directory

This directory is used for input files in ComfyUI workflows.

## Usage

1. Place input files here:
   - Images
   - Text files
   - Other workflow inputs

2. Access in workflows using relative paths

## Organization

- Use subdirectories for different projects
- Keep original files for reference
- Clean up unused files

## Supported Formats

- Images: PNG, JPG, WEBP
- Text: TXT, JSON
- Others based on workflow needs

## Best Practices

1. Organize files logically
2. Use clear naming conventions
3. Regular cleanup
4. Backup important files
"@ | Out-File -FilePath "input/README.md" -Encoding UTF8 -NoNewline

    # Create output directory README
    @"
# ComfyUI Output Directory

This directory stores outputs from ComfyUI workflows.

## Contents

- Generated images
- Processing results
- Workflow outputs

## Organization

- Outputs are organized by date
- Each workflow run creates its own files
- Preview images are generated automatically

## Management

1. Regular cleanup recommended
2. Backup important results
3. Monitor disk space usage
4. Remove temporary files

## Best Practices

1. Document important outputs
2. Use version control for workflows
3. Archive completed projects
4. Maintain disk space
"@ | Out-File -FilePath "output/README.md" -Encoding UTF8 -NoNewline

    # Create models directory README
    @"
# ComfyUI Models Directory

This directory contains model files for ComfyUI.

## Directory Structure

- checkpoints/: Main model files
- clip/: CLIP model files
- controlnet/: ControlNet models
- embeddings/: Textual embeddings
- loras/: LoRA adaptations
- upscale_models/: Upscaling models
- vae/: VAE models
- unet/: U-Net models

## Model Management

1. Download models from trusted sources
2. Verify checksums when available
3. Keep track of model versions
4. Document model combinations

## Storage Requirements

- Large disk space needed
- SSD recommended for performance
- Regular cleanup of unused models

## Best Practices

1. Organize models logically
2. Document model sources
3. Test model compatibility
4. Regular backups
5. Version control
6. Performance monitoring

## Security

1. Download from trusted sources
2. Verify file integrity
3. Monitor resource usage
4. Regular security updates
"@ | Out-File -FilePath "models/README.md" -Encoding UTF8 -NoNewline

    Write-Host "ComfyUI initialization complete!" -ForegroundColor Green
    return $true
}

function Cleanup-ComfyUI {
    Write-Host "`nCleaning up ComfyUI..." -ForegroundColor Cyan
    
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
        "input",
        "output",
        "custom_nodes",
        "models",
        "../volumes/comfyui/models/checkpoints",
        "../volumes/comfyui/models/clip",
        "../volumes/comfyui/models/controlnet",
        "../volumes/comfyui/models/embeddings",
        "../volumes/comfyui/models/loras",
        "../volumes/comfyui/models/upscale_models",
        "../volumes/comfyui/models/vae",
        "../volumes/comfyui/models/unet"
    )

    foreach ($dir in $dataDirectories) {
        Clear-Directory -Path $dir
    }

    # Remove ComfyUI repository
    if (Test-Path "repo") {
        Remove-Item -Recurse -Force "repo"
        Write-Host "Removed ComfyUI repository"
    }

    Write-Host "ComfyUI cleanup complete!" -ForegroundColor Green
}

# Execute the appropriate action
switch ($Action.ToLower()) {
    "setup" {
        Initialize-ComfyUI
    }
    "cleanup" {
        Cleanup-ComfyUI
    }
    default {
        Write-Host "Invalid action. Use 'setup' or 'cleanup'" -ForegroundColor Red
    }
}
