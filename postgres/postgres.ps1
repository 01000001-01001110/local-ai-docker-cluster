#!/usr/bin/env pwsh
# File: ./postgres/postgres.ps1
# Purpose: Handle PostgreSQL-specific setup and configuration

param(
    [Parameter(Position=0)]
    [string]$Action = "setup"
)

function Initialize-PostgreSQL {
    Write-Host "`nInitializing PostgreSQL..." -ForegroundColor Cyan
    
    # Create necessary directories if they don't exist
    $directories = @(
        ".",  # Ensure postgres directory exists
        "data/pgdata"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Force -Path $dir
            Write-Host "Created directory: $dir"
        }
    }

    # Create README
    @"
# PostgreSQL Configuration

This directory contains PostgreSQL data and configuration files.

## Directory Structure

- data/
  - pgdata/: PostgreSQL data directory

## Environment Variables

Required environment variables:
- POSTGRES_USER: Database username
- POSTGRES_PASSWORD: Database password
- POSTGRES_DB: Default database name

## Database Users

The initialization creates:
1. Root user (specified by POSTGRES_USER)
2. Database specified by POSTGRES_DB

## Integration with Other Services

PostgreSQL is used by:
- n8n for workflow storage
- Other services requiring relational database

## Backup and Restore

### Backup Database
```bash
# Replace variables with actual values
docker exec lai-postgres pg_dump -U username dbname > backup.sql
```

### Restore Database
```bash
# Replace variables with actual values
docker exec -i lai-postgres psql -U username dbname < backup.sql
```

## Security Notes

1. Change default credentials
2. Regular backups recommended
3. Monitor disk usage
4. Check logs for unauthorized access attempts

## Common Operations

### Connect to Database
```bash
docker exec -it lai-postgres psql -U \$POSTGRES_USER \$POSTGRES_DB
```

### List Databases
```sql
\\l
```

### List Tables
```sql
\\dt
```

### Show Users
```sql
\\du
```

## Troubleshooting

1. Check logs: `docker logs lai-postgres`
2. Verify connectivity: `pg_isready -h localhost -p 5432`
3. Test authentication
4. Check disk space
5. Common issues:
   - Permission denied: Check user privileges
   - Connection refused: Verify port and host settings
   - Database not found: Check database name
"@ | Out-File -FilePath "README.md" -Encoding UTF8 -NoNewline
    Write-Host "Created README.md"

    Write-Host "PostgreSQL initialization complete!" -ForegroundColor Green
    return $true
}

function Cleanup-PostgreSQL {
    Write-Host "`nCleaning up PostgreSQL..." -ForegroundColor Cyan
    
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
        "data/pgdata"
    )

    foreach ($dir in $dataDirectories) {
        Clear-Directory -Path $dir
    }

    Write-Host "PostgreSQL cleanup complete!" -ForegroundColor Green
}

# Execute the appropriate action
switch ($Action.ToLower()) {
    "setup" {
        Initialize-PostgreSQL
    }
    "cleanup" {
        Cleanup-PostgreSQL
    }
    default {
        Write-Host "Invalid action. Use 'setup' or 'cleanup'" -ForegroundColor Red
    }
}
