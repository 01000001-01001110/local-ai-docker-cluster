#!/usr/bin/env pwsh
# File: ./node-red/node-red.ps1
# Purpose: Handle Node-RED setup and configuration

param(
    [Parameter(Position=0)]
    [string]$Action = "setup"
)

function Initialize-NodeRED {
    Write-Host "`nInitializing Node-RED..." -ForegroundColor Cyan
    
    # Create necessary directories if they don't exist
    $directories = @(
        ".",  # Ensure node-red directory exists
        "data"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Force -Path $dir
            Write-Host "Created directory: $dir"
        }
    }

    # Create settings.js
    Write-Host "Creating Node-RED configuration..." -ForegroundColor Cyan
    @"
module.exports = {
    flowFile: 'flows.json',
    flowFilePretty: true,

    // Configure the file used to store credential secrets
    credentialSecret: process.env.NODE_RED_CREDENTIAL_SECRET || 'a-secret-key',

    // By default, all user data is stored in a directory called '.node-red' under
    // the user's home directory. To use a different location, the following
    // property can be used
    userDir: '/data',

    // Node-RED scans the `nodes` directory in the userDir to find local node files.
    // The following property can be used to specify an additional directory to scan.
    nodesDir: '/data/nodes',

    // Enables the welcome tour
    editorTheme: {
        tours: false,
        projects: {
            enabled: false
        }
    },

    // Configure how the runtime will handle external npm packages.
    // This covers:
    //  - whether the editor will allow new node modules to be installed
    //  - whether nodes, such as the Function node are allowed to have their
    //    own dynamically configured dependencies.
    //
    // It can have the following properties:
    //  - autoInstall
    //       Automatically install any missing modules the first time a node is deployed
    //  - autoInstallRetry
    //       Retry automatic node installation N times
    //  - maxModules
    //       The maximum number of node modules to automatically install
    //  - externalModules
    //       Allow Function nodes to have their own dynamically configured dependencies.
    //       - also enables installing npm modules from within the Function node editor
    externalModules: {
        autoInstall: true,
        autoInstallRetry: 2,
        maxModules: 50,
        palette: {
            allowInstall: true,
            allowUpload: true,
            allowList: []
        },
        modules: {
            allowInstall: true
        }
    },

    // The following property can be used to configure cross-origin resource sharing
    // in the HTTP nodes.
    // See https://github.com/troygoode/node-cors#configuration-options for
    // details on its contents.
    httpNodeCors: {
        origin: "*",
        methods: "GET,PUT,POST,DELETE"
    },

    // The maximum length, in characters, of any message sent to the debug sidebar tab
    debugMaxLength: 1000,

    // The maximum number of messages nodes will buffer internally as part of their
    // operation. This applies across a range of nodes that operate on message sequences.
    //  defaults to no limit. A value of 0 also means no limit is applied.
    nodeMessageBufferMaxLength: 0,

    // To disable the option for using local files for storing keys and certificates,
    // the following property can be set to true.
    // This allows the Function node to load additional npm modules directly
    functionGlobalContext: {
    },

    // The following property can be used to order the categories in the editor
    // palette. If a node's category is not in the list, the category will get
    // added to the end of the palette.
    // If not set, the following default order is used:
    paletteCategories: [
        'subflows',
        'common',
        'function',
        'network',
        'sequence',
        'parser',
        'storage'
    ],

    // Configure the logging output
    logging: {
        console: {
            level: "info",
            metrics: false,
            audit: false
        }
    }
}
"@ | Out-File -FilePath "data/settings.js" -Encoding UTF8 -NoNewline
    Write-Host "Created settings.js"

    # Create README
    @"
# Node-RED Configuration

This directory contains Node-RED configuration and flows.

## Directory Structure

- data/
  - settings.js: Main configuration file
  - flows.json: Flow definitions
  - nodes/: Custom nodes
  - lib/: Function node code

## Configuration

### Main Settings
- Flow file location
- Credential encryption
- Node installation
- Security settings
- Logging configuration

### External Modules

Settings for npm package handling:
- Auto-installation
- Maximum modules
- Allowed packages
- Installation retry

## Security Settings

1. Credential encryption
2. CORS configuration
3. Module restrictions
4. API access control

## Integration

Node-RED integrates with:
- MongoDB
- PostgreSQL
- External APIs
- Other containers

## Development

### Custom Nodes
1. Place in data/nodes/
2. Configure in settings.js
3. Restart service

### Function Nodes
- JavaScript environment
- External module support
- Global context

## Flow Management

1. Version control
2. Backup strategy
3. Testing approach
4. Deployment process

## Troubleshooting

1. Check logs:
   ```bash
   docker logs lai-node-red
   ```

2. Common issues:
   - Module installation
   - Flow deployment
   - Connection problems
   - Resource constraints

3. Debug:
   - Use debug nodes
   - Check system status
   - Monitor resources

## Best Practices

1. Regular backups
2. Flow documentation
3. Error handling
4. Resource monitoring
5. Security updates
6. Code organization

## Performance

1. Message buffering
2. Memory usage
3. CPU utilization
4. Network traffic

## Security Notes

1. Secure credentials
2. Access control
3. Module verification
4. Regular updates
"@ | Out-File -FilePath "README.md" -Encoding UTF8 -NoNewline
    Write-Host "Created README.md"

    Write-Host "Node-RED initialization complete!" -ForegroundColor Green
    return $true
}

function Cleanup-NodeRED {
    Write-Host "`nCleaning up Node-RED..." -ForegroundColor Cyan
    
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

    # Recreate configuration files
    Write-Host "Recreating Node-RED configuration..." -ForegroundColor Cyan
    Initialize-NodeRED | Out-Null

    Write-Host "Node-RED cleanup complete!" -ForegroundColor Green
}

# Execute the appropriate action
switch ($Action.ToLower()) {
    "setup" {
        Initialize-NodeRED
    }
    "cleanup" {
        Cleanup-NodeRED
    }
    default {
        Write-Host "Invalid action. Use 'setup' or 'cleanup'" -ForegroundColor Red
    }
}
