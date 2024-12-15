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
`ash
curl -X PUT 'http://localhost:6333/collections/my_collection' \\
    -H 'Content-Type: application/json' \\
    -d '{
        "vectors": {
            "size": 1536,
            "distance": "Cosine"
        }
    }'
`

### List Collections
`ash
curl 'http://localhost:6333/collections'
`

### Delete Collection
`ash
curl -X DELETE 'http://localhost:6333/collections/my_collection'
`

## Vector Operations

### Upload Vectors
`ash
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
`

### Search Vectors
`ash
curl -X POST 'http://localhost:6333/collections/my_collection/points/search' \\
    -H 'Content-Type: application/json' \\
    -d '{
        "vector": [0.05, 0.61, 0.76, ...],
        "limit": 10
    }'
`

## Backup and Snapshots

### Create Snapshot
`ash
curl -X POST 'http://localhost:6333/collections/my_collection/snapshots'
`

### List Snapshots
`ash
curl 'http://localhost:6333/collections/my_collection/snapshots'
`

### Restore from Snapshot
`ash
curl -X PUT 'http://localhost:6333/collections/my_collection/snapshots/snapshot-name'
`

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
   `ash
   docker logs lai-qdrant
   `

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