#!/usr/bin/env pwsh
# File: ./mongodb/mongodb.ps1
# Purpose: Handle MongoDB-specific setup and configuration

param(
    [Parameter(Position=0)]
    [string]$Action = "setup"
)

function Initialize-MongoDB {
    Write-Host "`nInitializing MongoDB..." -ForegroundColor Cyan
    
    # Create necessary directories if they don't exist
    $directories = @(
        ".",  # Ensure mongodb directory exists
        "data",
        "init"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Force -Path $dir
            Write-Host "Created directory: $dir"
        }
    }

    # Create initialization script
    Write-Host "Creating MongoDB initialization script..." -ForegroundColor Cyan
    @"
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
"@ | Out-File -FilePath "init/init-mongo.js" -Encoding UTF8 -NoNewline
    Write-Host "Created initialization script"

    # Create README
    @"
# MongoDB Configuration

This directory contains MongoDB data and initialization scripts.

## Directory Structure

- data/: MongoDB data files
- init/: Initialization scripts
  - init-mongo.js: Database setup script

## Environment Variables

Required environment variables:
- MONGODB_USER: Root username
- MONGODB_PASSWORD: Root password
- MONGODB_DATABASE: Default database name

## Vector Search

The initialization script sets up:
1. Root user creation
2. Default database
3. Vectors collection
4. Vector search index (1536 dimensions)

## Backup and Restore

### Backup Database
```bash
mongodump --uri="mongodb://username:password@localhost:27017/dbname?authSource=admin" --out=backup
```

### Restore Database
```bash
mongorestore --uri="mongodb://username:password@localhost:27017/dbname?authSource=admin" backup
```

## Security Notes

1. Change default credentials
2. Regular backups recommended
3. Monitor disk usage
4. Check logs for unauthorized access attempts

## Integration with Other Services

MongoDB is used by:
- Flowise
- n8n
- Vector storage
- Other AI components

## Troubleshooting

1. Check logs: `docker logs lai-mongodb`
2. Verify connectivity: `mongosh mongodb://localhost:27017`
3. Test authentication
4. Check disk space
"@ | Out-File -FilePath "README.md" -Encoding UTF8 -NoNewline
    Write-Host "Created README.md"

    Write-Host "MongoDB initialization complete!" -ForegroundColor Green
    return $true
}

function Cleanup-MongoDB {
    Write-Host "`nCleaning up MongoDB..." -ForegroundColor Cyan
    
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
        "init"
    )

    foreach ($dir in $dataDirectories) {
        Clear-Directory -Path $dir
    }

    # Recreate initialization script
    Write-Host "Recreating MongoDB initialization script..." -ForegroundColor Cyan
    Initialize-MongoDB | Out-Null

    Write-Host "MongoDB cleanup complete!" -ForegroundColor Green
}

# Execute the appropriate action
switch ($Action.ToLower()) {
    "setup" {
        Initialize-MongoDB
    }
    "cleanup" {
        Cleanup-MongoDB
    }
    default {
        Write-Host "Invalid action. Use 'setup' or 'cleanup'" -ForegroundColor Red
    }
}
