#Backup & Restore Joe-The-Dev config for Development
```md
# MacOS Development Environment Setup Script

This script automates the installation of essential tools and the restoration of your development environment configuration, including:
- **Homebrew**
- **Fish Shell** with **Oh My Fish**
- **Neovim**
- Restoring configurations for Fish and Neovim from a private Git repository.

## Features
- Installs **Homebrew**, **Fish shell**, **Oh My Fish**, and **Neovim** automatically.
- Sets Fish shell as the default shell.
- Restores your **Fish** and **Neovim** configuration from a backup repository.
- Optionally restores `.env` files.

## Prerequisites
Before running the script, ensure you have:
1. **macOS** with **Xcode Command Line Tools** installed (the script will prompt you to install it if necessary).
2. A **private Git repository** containing backups of your Fish, Neovim configurations, and optionally a `.env` file.
3. **SSH keys** set up and added to your GitHub or GitLab account for authentication.

## Backup Repository Structure
Your backup repository should have the following structure:
```
config_backup/
├── fish/      # Fish shell configuration (e.g., ~/.config/fish)
├── nvim/      # Neovim configuration (e.g., ~/.config/nvim)
└── .env       # Optional .env file
```

## Installation

1. Clone this repository (or copy the `init.sh` script to your local machine).
2. Open the `init.sh` script and replace the `REPO_URL` with your private backup repository's SSH URL:

   ```bash
   REPO_URL="git@your-repo-url.git"
   ```

3. Make the script executable:

   ```bash
   chmod +x init.sh
   ```

4. Run the script:

   ```bash
   ./init.sh
   ```

The script will:
- Install the necessary tools (Homebrew, Fish, Oh My Fish, and Neovim).
- Clone your configuration from the backup repository.
- Restore your Fish and Neovim configurations.
- Start Fish shell as the default shell.

## Usage

### Running the Script

To set up your development environment on a new macOS machine:

1. Open a terminal.
2. Navigate to the directory where the script is stored.
3. Run the script as follows:

   ```bash
   ./init.sh
   ```

The script will handle the installation and restoration of your environment automatically.

### Restoring Your Environment
If you need to restore your configuration after migration (e.g., on a new laptop), just run the script again. It will:
- Clone (or update) your backup repository.
- Restore your Fish and Neovim configurations.
- Restore your `.env` file, if present.

## Customization
You can customize the script to include more tools or specific configurations by modifying the `init.sh` script:
- Add more **Homebrew** packages or tools you need.
- Customize the **Fish** and **Neovim** settings based on your preferences.

## Troubleshooting

- **Homebrew is already installed:** If you already have Homebrew installed, the script will skip the installation step.
- **Fish shell not set as default:** If Fish is not set as the default shell after the script runs, ensure that Fish has been added to the list of allowed shells by running:

  ```bash
  echo "/usr/local/bin/fish" | sudo tee -a /etc/shells
  chsh -s /usr/local/bin/fish
  ```

- **SSH authentication failed:** Ensure your SSH keys are correctly configured and added to your GitHub/GitLab account for private repository access.

## License
This project is licensed under the MIT License.
```

This version is ready for use as your `README.md` file. Let me know if you need any further changes! jdd-cfg
