#!/usr/bin/env pwsh
# File: ./n8n/n8n.ps1
# Purpose: Handle n8n-specific setup and configuration

param(
    [Parameter(Position=0)]
    [string]$Action = "setup"
)

function Initialize-N8N {
    Write-Host "`nInitializing n8n..." -ForegroundColor Cyan
    
    # Create necessary directories if they don't exist
    $directories = @(
        ".",  # Ensure n8n directory exists
        "data",
        "backup/workflows",
        "backup/credentials"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Force -Path $dir
            Write-Host "Created directory: $dir"
        }
    }

    # Create default workflow backup
    Write-Host "Creating default workflow..." -ForegroundColor Cyan
    @"
{
    "id": 1,
    "name": "Welcome Workflow",
    "active": false,
    "nodes": [
        {
            "parameters": {},
            "id": "12345678-1234-1234-1234-123456789012",
            "name": "Start",
            "type": "n8n-nodes-base.start",
            "typeVersion": 1,
            "position": [
                250,
                300
            ]
        }
    ],
    "connections": {},
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z",
    "settings": {
        "saveExecutionProgress": true,
        "saveManualExecutions": true,
        "callerPolicy": "workflowsFromSameOwner",
        "errorWorkflow": ""
    },
    "staticData": null,
    "tags": []
}
"@ | Out-File -FilePath "backup/workflows/welcome.json" -Encoding UTF8 -NoNewline
    Write-Host "Created welcome workflow"

    # Create default credentials backup
    Write-Host "Creating default credentials backup..." -ForegroundColor Cyan
    @"
{
    "id": 1,
    "name": "Example Credentials",
    "data": "CREDENTIALS_ENCRYPTED",
    "type": "default",
    "nodesAccess": [],
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
}
"@ | Out-File -FilePath "backup/credentials/example.json" -Encoding UTF8 -NoNewline
    Write-Host "Created example credentials"

    # Create README
    @"
# n8n Configuration

This directory contains n8n configuration, workflows, and credentials.

## Directory Structure

- data/
  - .n8n/: Runtime data
  - database.sqlite: SQLite database (if used)
- backup/
  - workflows/: Workflow backups
  - credentials/: Credentials backups

## Environment Variables

Important environment variables:
- DB_TYPE: Database type (sqlite, postgresdb)
- DB_POSTGRESDB_HOST: PostgreSQL host
- DB_POSTGRESDB_PORT: PostgreSQL port
- DB_POSTGRESDB_USER: PostgreSQL user
- DB_POSTGRESDB_PASSWORD: PostgreSQL password
- DB_POSTGRESDB_DATABASE: PostgreSQL database
- N8N_ENCRYPTION_KEY: Encryption key for credentials
- N8N_USER_MANAGEMENT_JWT_SECRET: JWT secret for user management

## Backup and Restore

### Export Workflows
```bash
docker exec lai-n8n n8n export:workflow --all --output=/backup/workflows
```

### Export Credentials
```bash
docker exec lai-n8n n8n export:credentials --all --output=/backup/credentials
```

### Import Workflows
```bash
docker exec lai-n8n n8n import:workflow --separate --input=/backup/workflows
```

### Import Credentials
```bash
docker exec lai-n8n n8n import:credentials --separate --input=/backup/credentials
```

## Security Notes

1. Keep encryption keys secure
2. Regularly backup workflows and credentials
3. Use environment variables for sensitive data
4. Review credential access permissions

## Integration with Other Services

n8n can integrate with:
- MongoDB
- PostgreSQL
- Redis
- External APIs
- Other containers in the network

## Troubleshooting

1. Check logs:
   ```bash
   docker logs lai-n8n
   ```

2. Common issues:
   - Database connection
   - Encryption keys
   - Import/export errors
   - Workflow execution

3. Database:
   - Check connection
   - Verify credentials
   - Monitor space

4. Workflows:
   - Validate syntax
   - Check credentials
   - Test connections

## Best Practices

1. Regular backups
2. Version control workflows
3. Document integrations
4. Monitor executions
5. Security updates
6. Resource planning

## Maintenance

1. Database:
   - Regular backups
   - Performance tuning
   - Space management

2. Workflows:
   - Regular testing
   - Update integrations
   - Clean old executions

3. Security:
   - Update credentials
   - Check permissions
   - Monitor access
"@ | Out-File -FilePath "README.md" -Encoding UTF8 -NoNewline
    Write-Host "Created README.md"

    Write-Host "n8n initialization complete!" -ForegroundColor Green
    return $true
}

function Cleanup-N8N {
    Write-Host "`nCleaning up n8n..." -ForegroundColor Cyan
    
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
        "backup/workflows",
        "backup/credentials"
    )

    foreach ($dir in $dataDirectories) {
        Clear-Directory -Path $dir
    }

    # Recreate default files
    Write-Host "Recreating n8n configuration..." -ForegroundColor Cyan
    Initialize-N8N | Out-Null

    Write-Host "n8n cleanup complete!" -ForegroundColor Green
}

# Execute the appropriate action
switch ($Action.ToLower()) {
    "setup" {
        Initialize-N8N
    }
    "cleanup" {
        Cleanup-N8N
    }
    default {
        Write-Host "Invalid action. Use 'setup' or 'cleanup'" -ForegroundColor Red
    }
}
