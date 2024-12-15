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
`ash
# Replace variables with actual values
docker exec lai-postgres pg_dump -U username dbname > backup.sql
`

### Restore Database
`ash
# Replace variables with actual values
docker exec -i lai-postgres psql -U username dbname < backup.sql
`

## Security Notes

1. Change default credentials
2. Regular backups recommended
3. Monitor disk usage
4. Check logs for unauthorized access attempts

## Common Operations

### Connect to Database
`ash
docker exec -it lai-postgres psql -U \ \
`

### List Databases
`sql
\\l
`

### List Tables
`sql
\\dt
`

### Show Users
`sql
\\du
`

## Troubleshooting

1. Check logs: docker logs lai-postgres
2. Verify connectivity: pg_isready -h localhost -p 5432
3. Test authentication
4. Check disk space
5. Common issues:
   - Permission denied: Check user privileges
   - Connection refused: Verify port and host settings
   - Database not found: Check database name