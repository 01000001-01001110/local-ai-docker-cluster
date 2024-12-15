# Open WebUI Configuration

This directory contains Open WebUI configuration and data files.

## Directory Structure

- data/
  - config.json: Main configuration file
  - chat_history/: User chat histories
  - models/: Model-specific settings

## Configuration

### Theme Settings
- Default and dark mode support
- Customizable interface elements

### Model Configuration
Default models supported:
- tinyllama (1.1B parameters)
- mistral-7b
- codellama-7b
- nomic-embed-text

### Interface Options
- System prompt visibility
- Model name display
- Timestamps
- Copy buttons
- Chat history
- Code highlighting
- LaTeX rendering

### Chat Settings
- History length
- Temperature
- Top-p sampling
- Top-k sampling
- Repeat penalty
- Maximum tokens

## Integration with Ollama

The WebUI connects to Ollama for:
- Model management
- Inference requests
- Embeddings generation

## Usage Guide

1. Access the interface at http://localhost:3003
2. Start with tinyllama model (lightweight)
3. Configure chat parameters
4. Start chatting!

## Model Management

### Adding New Models
1. Pull models through Ollama
2. Add model names to config.json
3. Restart the service

### Model Parameters
Customize per-model settings:
- Context length
- Temperature
- Top-p/Top-k
- Repeat penalty

## Security Notes

1. No authentication by default
2. Use Nginx Proxy Manager for access control
3. Monitor resource usage
4. Regular backups recommended

## Troubleshooting

1. Check logs:
   `ash
   docker logs lai-open-webui
   `

2. Common issues:
   - Model loading failures
   - Memory constraints
   - GPU access problems
   - Network connectivity

3. Performance:
   - Adjust GPU layers
   - Monitor memory usage
   - Check model loading times

## Backup and Restore

Important files to backup:
- config.json
- Chat histories
- Custom model settings

## Best Practices

1. Regular configuration backups
2. Monitor resource usage
3. Update models regularly
4. Test new models before production
5. Keep chat histories manageable
6. Use appropriate model parameters