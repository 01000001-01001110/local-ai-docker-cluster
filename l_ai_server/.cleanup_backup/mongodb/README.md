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
`ash
mongodump --uri="mongodb://username:password@localhost:27017/dbname?authSource=admin" --out=backup
`

### Restore Database
`ash
mongorestore --uri="mongodb://username:password@localhost:27017/dbname?authSource=admin" backup
`

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

1. Check logs: docker logs lai-mongodb
2. Verify connectivity: mongosh mongodb://localhost:27017
3. Test authentication
4. Check disk space