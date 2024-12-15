# File: ./switch-mode.ps1
# Purpose: Helper script to switch between CPU and GPU modes on Windows with improved error handling

function Test-GPU {
    try {
        $null = nvidia-smi
        return $true
    } catch {
        return $false
    }
}

function Clean-DockerResources {
    Write-Host "Performing thorough cleanup..."
    
    # First, stop all containers and remove compose resources
    Write-Host "Stopping all containers and removing compose resources..."
    docker compose down --volumes --remove-orphans --timeout 30
    
    # Force remove any stuck containers
    Write-Host "Removing any stuck containers..."
    $stuckContainers = docker ps -aq
    if ($stuckContainers) {
        docker rm -f $stuckContainers
    }
    
    # Remove the specific network if it exists
    Write-Host "Removing existing networks..."
    $networkName = "local_ai_server_demo"
    $existingNetwork = docker network ls --filter "name=$networkName" -q
    if ($existingNetwork) {
        # Force disconnect any connected containers
        $connectedContainers = docker network inspect $networkName -f '{{range .Containers}}{{.Name}} {{end}}' 2>$null
        if ($connectedContainers) {
            foreach ($container in $connectedContainers.Split()) {
                if ($container) {
                    docker network disconnect -f $networkName $container 2>$null
                }
            }
        }
        docker network rm $networkName 2>$null
    }
    
    # Clean up any other unused networks
    docker network prune -f
    
    Write-Host "Cleanup complete."
    Start-Sleep -Seconds 5
}

function Initialize-Network {
    Write-Host "Initializing Docker network..."
    
    # Remove the network if it exists
    $networkName = "local_ai_server_demo"
    $existingNetwork = docker network ls --filter "name=$networkName" -q
    if ($existingNetwork) {
        docker network rm $existingNetwork 2>$null
        Start-Sleep -Seconds 2
    }
    
    # Create a fresh network
    docker network create $networkName
    Write-Host "Network initialized."
}

function Start-Environment {
    # Perform thorough cleanup
    Clean-DockerResources
    
    # Start services based on GPU availability
    if (Test-GPU) {
        Write-Host "GPU detected - starting with GPU support..."
        docker compose --profile gpu-nvidia up -d --force-recreate
    } else {
        Write-Host "No GPU detected - starting in CPU mode..."
        docker compose --profile cpu up -d --force-recreate
    }
    
    # Give services more time to initialize
    Write-Host "Waiting for services to initialize..."
    Start-Sleep -Seconds 30
    
    # Verify services status
    Write-Host "Checking service status..."
    docker compose ps
    
    # Display logs if there are issues
    if (-not (docker ps --filter "name=n8n" --filter "status=running" -q)) {
        Write-Host "n8n container not running. Checking logs..."
        docker compose logs n8n
        Write-Host "`nChecking Postgres logs for potential database issues..."
        docker compose logs postgres
    }
}

# Main script execution
$action = $args[0]
switch ($action) {
    "start" { Start-Environment }
    "stop" { Clean-DockerResources }
    "restart" { 
        Clean-DockerResources
        Start-Sleep -Seconds 5
        Start-Environment 
    }
    default {
        Write-Host "Usage: .\switch-mode.ps1 {start|stop|restart}"
        exit 1
    }
}