#!/usr/bin/env pwsh
# File: ./qdrant/qdrant.ps1
# Purpose: Handle Qdrant vector database setup and configuration

param(
    [Parameter(Position=0)]
    [string]$Action = "setup"
)

function Initialize-Qdrant {
    Write-Host "`nInitializing Qdrant..." -ForegroundColor Cyan
    
    # Create necessary directories if they don't exist
    $directories = @(
        ".",  # Ensure qdrant directory exists
        "storage"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Force -Path $dir
            Write-Host "Created directory: $dir"
        }
    }

    # Create config.yaml
    Write-Host "Creating Qdrant configuration..." -ForegroundColor Cyan
    @"
storage:
  # Storage persistence path
  storage_path: /qdrant/storage

  # Write-ahead-log persistence path
  wal_path: /qdrant/storage/wal

  # Snapshots path
  snapshots_path: /qdrant/storage/snapshots

  # Path for temporary files
  temp_path: /qdrant/storage/temp

  # Maximum number of concurrent threads for optimization
  optimizer_cpu_budget: 2

  # Maximum number of threads for parallel processing
  max_search_threads: 4

service:
  # Host to bind the service to
  host: 0.0.0.0
  # HTTP port to bind the service to
  http_port: 6333
  # gRPC port to bind the service to
  grpc_port: 6334

cluster:
  # Enabled cluster mode
  enabled: false

telemetry:
  # Disable usage statistics collection
  enabled: false

log_level: INFO
"@ | Out-File -FilePath "storage/config.yaml" -Encoding UTF8 -NoNewline
    Write-Host "Created config.yaml"

    # Create README
    @"
# Qdrant Vector Database Configuration

This directory contains Qdrant configuration and storage.

## Directory Structure

- storage/
  - config.yaml: Main configuration file
  - collections/: Vector collections
  - snapshots/: Database snapshots
  - wal/: Write-ahead logs
  - temp/: Temporary files

## Configuration

### Storage Settings
- Persistent storage path
- Write-ahead-log path
- Snapshots location
- Temporary files directory
- Optimization threads
- Search threads

### Service Configuration
- HTTP port: 6333
- gRPC port: 6334
- Host binding: 0.0.0.0

## Collections Management

### Create Collection
```bash
curl -X PUT 'http://localhost:6333/collections/my_collection' \\
    -H 'Content-Type: application/json' \\
    -d '{
        "vectors": {
            "size": 1536,
            "distance": "Cosine"
        }
    }'
```

### List Collections
```bash
curl 'http://localhost:6333/collections'
```

### Delete Collection
```bash
curl -X DELETE 'http://localhost:6333/collections/my_collection'
```

## Vector Operations

### Upload Vectors
```bash
curl -X PUT 'http://localhost:6333/collections/my_collection/points' \\
    -H 'Content-Type: application/json' \\
    -d '{
        "points": [
            {
                "id": 1,
                "vector": [0.05, 0.61, 0.76, ...],
                "payload": {"text": "sample"}
            }
        ]
    }'
```

### Search Vectors
```bash
curl -X POST 'http://localhost:6333/collections/my_collection/points/search' \\
    -H 'Content-Type: application/json' \\
    -d '{
        "vector": [0.05, 0.61, 0.76, ...],
        "limit": 10
    }'
```

## Backup and Snapshots

### Create Snapshot
```bash
curl -X POST 'http://localhost:6333/collections/my_collection/snapshots'
```

### List Snapshots
```bash
curl 'http://localhost:6333/collections/my_collection/snapshots'
```

### Restore from Snapshot
```bash
curl -X PUT 'http://localhost:6333/collections/my_collection/snapshots/snapshot-name'
```

## Integration

Qdrant integrates with:
- Langchain
- LlamaIndex
- Direct API calls
- Custom applications

## Performance Tuning

### Memory Management
- Monitor RAM usage
- Adjust cache sizes
- Optimize index parameters

### Search Optimization
- Use appropriate index type
- Adjust search parameters
- Monitor query times

## Security Notes

1. No authentication by default
2. Use firewall rules
3. Monitor access logs
4. Regular backups
5. Secure API endpoints

## Troubleshooting

1. Check logs:
   ```bash
   docker logs lai-qdrant
   ```

2. Common issues:
   - Memory constraints
   - Index corruption
   - Network connectivity
   - Query performance

3. Performance:
   - Monitor index size
   - Check query latency
   - Verify resource usage

## Best Practices

1. Regular backups
2. Monitor performance
3. Index optimization
4. Resource planning
5. Security measures
6. Documentation
7. Testing strategy

## Resource Management

### Storage
- Monitor disk usage
- Regular cleanup
- Snapshot management

### Memory
- Configure cache size
- Monitor RAM usage
- Optimize indexes
"@ | Out-File -FilePath "README.md" -Encoding UTF8 -NoNewline
    Write-Host "Created README.md"

    Write-Host "Qdrant initialization complete!" -ForegroundColor Green
    return $true
}

function Cleanup-Qdrant {
    Write-Host "`nCleaning up Qdrant..." -ForegroundColor Cyan
    
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
        "storage"
    )

    foreach ($dir in $dataDirectories) {
        Clear-Directory -Path $dir
    }

    # Recreate configuration
    Write-Host "Recreating Qdrant configuration..." -ForegroundColor Cyan
    Initialize-Qdrant | Out-Null

    Write-Host "Qdrant cleanup complete!" -ForegroundColor Green
}

# Execute the appropriate action
switch ($Action.ToLower()) {
    "setup" {
        Initialize-Qdrant
    }
    "cleanup" {
        Cleanup-Qdrant
    }
    default {
        Write-Host "Invalid action. Use 'setup' or 'cleanup'" -ForegroundColor Red
    }
}
