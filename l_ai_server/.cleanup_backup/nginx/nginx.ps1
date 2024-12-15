#!/usr/bin/env pwsh
# File: ./nginx/nginx.ps1
# Purpose: Handle Nginx Proxy Manager setup and configuration

param(
    [Parameter(Position=0)]
    [string]$Action = "setup"
)

function Initialize-Nginx {
    Write-Host "`nInitializing Nginx Proxy Manager..." -ForegroundColor Cyan
    
    # Create necessary directories if they don't exist
    $directories = @(
        ".",  # Ensure nginx directory exists
        "data",
        "letsencrypt"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Force -Path $dir
            Write-Host "Created directory: $dir"
        }
    }

    # Create README
    @"
# Nginx Proxy Manager Configuration

This directory contains Nginx Proxy Manager data and SSL certificates.

## Directory Structure

- data/: Configuration and database files
- letsencrypt/: SSL certificates and related files

## Default Credentials

Initial login credentials:
- Email: admin@example.com
- Password: changeme

**Important:** Change these credentials after first login!

## Available Services

Default ports for local services:
- Perplexica Frontend: 3000
- Perplexica Backend: 3001
- Flowise: 3002
- Open WebUI: 3003
- SearxNG: 4000
- n8n: 5678
- Node-RED: 1880
- ComfyUI: 8189

## Proxy Setup Guide

1. Access admin panel at http://localhost:81
2. Log in with default credentials
3. Add Proxy Host:
   - Domain Names: your-domain.com
   - Scheme: http or https
   - Forward IP/Host: service-name (e.g., lai-perplexica)
   - Forward Port: service port (e.g., 3000)

## SSL Certificates

1. Let's Encrypt Integration:
   - Automatic certificate generation
   - Automatic renewal
   - Wildcard certificates supported

2. Custom Certificates:
   - Upload through admin interface
   - Store in letsencrypt directory

## Security Notes

1. Change default admin credentials immediately
2. Use strong passwords
3. Enable SSL for all public services
4. Regular backups recommended
5. Monitor access logs
6. Keep certificates up to date

## Backup and Restore

Important directories to backup:
- data/: Contains configuration
- letsencrypt/: Contains SSL certificates

## Troubleshooting

1. Check logs:
   ```bash
   docker logs lai-nginx
   ```

2. Common issues:
   - Port conflicts
   - SSL certificate errors
   - DNS resolution problems
   - Proxy connection timeouts

3. SSL Certificate Issues:
   - Verify domain DNS
   - Check Let's Encrypt rate limits
   - Validate certificate paths

4. Access Issues:
   - Verify service is running
   - Check proxy host configuration
   - Validate target service port
   - Check network connectivity

## Network Configuration

The proxy manager is part of the 'lai' network and can access other services by their container names:
- lai-perplexica
- lai-flowise
- lai-open-webui
- lai-searxng
- lai-n8n
- lai-node-red
- lai-comfyui

## Port Mappings

- 80: HTTP
- 81: Admin Interface
- 443: HTTPS

## Best Practices

1. Always use HTTPS for production
2. Set up regular certificate renewal checks
3. Monitor SSL certificate expiration
4. Keep regular configuration backups
5. Use strong passwords
6. Enable access controls
7. Monitor logs for security issues
"@ | Out-File -FilePath "README.md" -Encoding UTF8 -NoNewline
    Write-Host "Created README.md"

    Write-Host "Nginx Proxy Manager initialization complete!" -ForegroundColor Green
    return $true
}

function Cleanup-Nginx {
    Write-Host "`nCleaning up Nginx Proxy Manager..." -ForegroundColor Cyan
    
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
        "letsencrypt"
    )

    foreach ($dir in $dataDirectories) {
        Clear-Directory -Path $dir
    }

    Write-Host "Nginx Proxy Manager cleanup complete!" -ForegroundColor Green
}

# Execute the appropriate action
switch ($Action.ToLower()) {
    "setup" {
        Initialize-Nginx
    }
    "cleanup" {
        Cleanup-Nginx
    }
    default {
        Write-Host "Invalid action. Use 'setup' or 'cleanup'" -ForegroundColor Red
    }
}
