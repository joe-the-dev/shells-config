# Environment Variables

This directory contains environment variable configurations.

## Files:
- `template.env`: Template with example variables
- `home.env`: Backup of ~/.env (if exists)

## Usage:
1. Copy `template.env` to `~/.env` or `$SHELL_BACKUP_DIR/.env`
2. Customize with your actual values
3. The Fish shell will automatically load these variables on startup

## Security Note:
- Never commit actual API keys or secrets
- Use placeholder values in templates
- Consider using a password manager for sensitive values
