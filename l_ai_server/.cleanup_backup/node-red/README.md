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
   `ash
   docker logs lai-node-red
   `

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