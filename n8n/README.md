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
`ash
docker exec lai-n8n n8n export:workflow --all --output=/backup/workflows
`

### Export Credentials
`ash
docker exec lai-n8n n8n export:credentials --all --output=/backup/credentials
`

### Import Workflows
`ash
docker exec lai-n8n n8n import:workflow --separate --input=/backup/workflows
`

### Import Credentials
`ash
docker exec lai-n8n n8n import:credentials --separate --input=/backup/credentials
`

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
   `ash
   docker logs lai-n8n
   `

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