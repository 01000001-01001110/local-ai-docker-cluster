# Nginx Proxy Manager Configuration

This directory contains Nginx Proxy Manager data and SSL certificates.

## Directory Structure

- data/: Configuration and database files
- letsencrypt/: SSL certificates and related files

## Default Credentials

Initial login credentials:
- Email: admin@example.com
- Password: changeme

**Important:** Change these credentials after first login!

## Available Services

Default ports for local services:
- Perplexica Frontend: 3000
- Perplexica Backend: 3001
- Flowise: 3002
- Open WebUI: 3003
- SearxNG: 4000
- n8n: 5678
- Node-RED: 1880
- ComfyUI: 8189

## Proxy Setup Guide

1. Access admin panel at http://localhost:81
2. Log in with default credentials
3. Add Proxy Host:
   - Domain Names: your-domain.com
   - Scheme: http or https
   - Forward IP/Host: service-name (e.g., lai-perplexica)
   - Forward Port: service port (e.g., 3000)

## SSL Certificates

1. Let's Encrypt Integration:
   - Automatic certificate generation
   - Automatic renewal
   - Wildcard certificates supported

2. Custom Certificates:
   - Upload through admin interface
   - Store in letsencrypt directory

## Security Notes

1. Change default admin credentials immediately
2. Use strong passwords
3. Enable SSL for all public services
4. Regular backups recommended
5. Monitor access logs
6. Keep certificates up to date

## Backup and Restore

Important directories to backup:
- data/: Contains configuration
- letsencrypt/: Contains SSL certificates

## Troubleshooting

1. Check logs:
   `ash
   docker logs lai-nginx
   `

2. Common issues:
   - Port conflicts
   - SSL certificate errors
   - DNS resolution problems
   - Proxy connection timeouts

3. SSL Certificate Issues:
   - Verify domain DNS
   - Check Let's Encrypt rate limits
   - Validate certificate paths

4. Access Issues:
   - Verify service is running
   - Check proxy host configuration
   - Validate target service port
   - Check network connectivity

## Network Configuration

The proxy manager is part of the 'lai' network and can access other services by their container names:
- lai-perplexica
- lai-flowise
- lai-open-webui
- lai-searxng
- lai-n8n
- lai-node-red
- lai-comfyui

## Port Mappings

- 80: HTTP
- 81: Admin Interface
- 443: HTTPS

## Best Practices

1. Always use HTTPS for production
2. Set up regular certificate renewal checks
3. Monitor SSL certificate expiration
4. Keep regular configuration backups
5. Use strong passwords
6. Enable access controls
7. Monitor logs for security issues