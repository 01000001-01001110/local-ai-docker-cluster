# Welcome to my Local AI Docker Cluster

![image](https://github.com/user-attachments/assets/cf25f9d6-6ba5-49d5-8f98-9aa89ad565bc)

=======
# Local AI Server

A comprehensive AI development environment that combines multiple services for AI/ML workflows, automation, and proxy management.

## Services

- **Nginx Proxy Manager** (Ports: 80, 81, 443)
  - Web interface available at http://localhost:81
  - Default login:
    - Email: admin@example.com
    - Password: changeme
    - *Change these credentials after first login*

- **Node-RED** (Port: 1880)
  - Flow-based programming tool
  - Web interface: http://localhost:1880

- **Perplexica** (Ports: 3000, 3001)
  - Frontend: http://localhost:3000
  - Backend API: http://localhost:3001

- **Flowise** (Port: 3002)
  - Low-code AI flow builder
  - Web interface: http://localhost:3002

- **Open WebUI** (Port: 3003)
  - Interface for AI model interaction
  - Web interface: http://localhost:3003

- **SearxNG** (Port: 4000)
  - Privacy-focused metasearch engine
  - Web interface: http://localhost:4000

- **n8n** (Port: 5678)
  - Workflow automation tool
  - Web interface: http://localhost:5678

- **Additional Services**
  - Qdrant Vector Database (Port: 6333)
  - MongoDB (Port: 27017)
  - PostgreSQL (Port: 5432)
  - Ollama (Port: 11434)

## Prerequisites

- Docker
- Docker Compose
- Git

## Directory Structure

```
.
├── .env                    # Environment variables
├── config.toml            # Configuration file
├── docker-compose.yml     # Main compose file
├── nginx/                 # Nginx Proxy Manager data
├── node-red/              # Node-RED data
├── flowise/              # Flowise data and storage
├── mongodb/              # MongoDB data and init scripts
├── n8n/                  # n8n workflows and credentials
├── ollama/               # Ollama models
├── open-webui/           # Open WebUI data
├── perplexica/           # Perplexica application
├── postgres/             # PostgreSQL data
├── qdrant/               # Qdrant storage
└── shared/               # Shared data between services
```

## Setup Instructions

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd local_ai_server
   ```

2. Create and configure the .env file:
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

3. Initialize the project structure:
   ```bash
   ./setup.ps1  # For Windows
   # OR
   ./setup.sh   # For Linux/Mac
   ```

4. Start the services:
   ```bash
   # For CPU-only setup
   docker compose --profile cpu up -d

   # For NVIDIA GPU setup
   docker compose --profile gpu-nvidia up -d
   ```

5. Access the services through their respective ports as listed above.

## Configuration

### Environment Variables (.env)
- `POSTGRES_USER`: PostgreSQL username
- `POSTGRES_PASSWORD`: PostgreSQL password
- `POSTGRES_DB`: PostgreSQL database name
- `MONGODB_USER`: MongoDB username
- `MONGODB_PASSWORD`: MongoDB password
- `MONGODB_DATABASE`: MongoDB database name
- `N8N_ENCRYPTION_KEY`: Encryption key for n8n
- `N8N_USER_MANAGEMENT_JWT_SECRET`: JWT secret for n8n

### Profiles
- `cpu`: For CPU-only deployment
- `gpu-nvidia`: For NVIDIA GPU support

## Usage

### Nginx Proxy Manager
1. Access the admin interface at http://localhost:81
2. Log in with default credentials
3. Set up proxy hosts for your services

### Node-RED
1. Access the editor at http://localhost:1880
2. Create and deploy your flows
3. Data persists in ./node-red/data

### Perplexica
- Frontend available at http://localhost:3000
- Backend API at http://localhost:3001
- Configure through config.toml

## Maintenance

### Backup
Important directories to backup:
- ./nginx/data
- ./nginx/letsencrypt
- ./node-red/data
- ./mongodb/data
- ./postgres/data
- ./n8n/data
- ./perplexica/data

### Cleanup
To remove all containers and clean up:
```bash
./cleanup.ps1  # For Windows
# OR
./cleanup.sh   # For Linux/Mac
```

## Security Notes

- Change default passwords immediately after first login
- Keep your .env file secure and never commit it to version control
- Regularly update your containers for security patches
- Use strong passwords for all services
- Consider implementing SSL for production use

## Troubleshooting

1. If services fail to start:
   - Check logs: `docker compose logs [service-name]`
   - Ensure all required ports are available
   - Verify file permissions on mounted volumes

2. If you can't connect to a service:
   - Verify the service is running: `docker compose ps`
   - Check if the port is correctly mapped
   - Ensure no firewall is blocking access

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

[MIT License](LICENSE)
>>>>>>> c6a5b87 (Initial commit)
