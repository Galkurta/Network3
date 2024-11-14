# Network3 Node Installation Guide

This guide will help you set up and run a Network3 node on your server. Follow these steps carefully to ensure proper installation and configuration.

## Prerequisites

- Ubuntu 20.04 LTS or higher
- Minimum 2 CPU cores
- Minimum 4GB RAM
- Minimum 50GB SSD
- Open port 8080

## Registration

1. Create an account at [Network3 Registration](https://account.network3.ai/register_page?rc=d21b34ed)
2. Log in to your account after registration

## Installation Methods

### Using WGET

One-line installation:

```bash
wget https://raw.githubusercontent.com/Galkurta/Network3/main/network3.sh && chmod +x network3.sh && sudo ./network3.sh
```

### Using CURL

One-line installation:

```bash
curl -fsSL https://raw.githubusercontent.com/Galkurta/Network3/main/network3.sh -o network3.sh&& chmod +x network3.sh && sudo ./network3.sh
```

## Node Setup

1. From the main menu, select option 1 to install prerequisites
2. Wait for the installation process to complete
3. The script will display your API key and sync link
4. Go to the sync link displayed in your terminal
5. Click the "+" button in the web interface
6. Paste your API key and click OK

## Menu Options

- Install Prerequisites: Install and configure the node
- Start: Start the node service
- Stop: Stop the node service
- Restart: Restart the node service
- View logs: Display node logs
- Show API Info: Display node API key and sync link
- Exit: Close the application

## Node Synchronization

1. After installation, go to your sync link: `https://account.network3.ai/main?o=YOUR_SERVER_IP:8080`
2. Click the "+" button in the top-right corner
3. Paste your API key in the input field
4. Click OK to synchronize your node

![Node Synchronization](https://i.ibb.co/QjPTgc7/sync.png)

## Screen Command Usage

### Basic Screen Commands

```bash
# List all screen sessions
screen -ls

# Attach to a screen session
screen -r network3

# Create a new screen session
screen -S network3

# Detach from screen session
# Press Ctrl+A, then D

# Kill a screen session
screen -X -S network3 quit
```

## Important Notes

- To detach from the screen session: Press `CTRL+A, D`
- To terminate the screen session: Press `CTRL+C`
- Keep your API key secure and never share it
- Ensure port 8080 is open on your server
- Regular system updates are recommended
- Make sure you have either `wget` or `curl` installed on your system
- Use `sudo apt install wget` or `sudo apt install curl` if needed
- Always verify the script source before executing

## Troubleshooting

Common issues and solutions:

1. **Port 8080 is not accessible**

   ```bash
   # Check if port is open
   sudo lsof -i :8080

   # Open port in UFW firewall
   sudo ufw allow 8080
   ```

2. **Screen session issues**

   ```bash
   # Remove all network3 screen sessions
   screen -ls | grep network3 | cut -d. -f1 | xargs -I {} screen -S {} -X quit
   ```

3. **Permission denied**
   ```bash
   # Give execute permission
   chmod +x network3.sh
   ```

## Support

If you encounter any issues or need assistance:

- Visit the official Network3 documentation
- Join the Network3 community on Discord
- Follow Network3 on Twitter for updates
- Check GitHub issues for known problems

## Updates

To update your node:

```bash
# Stop the current node
./network3.sh
# Select option 3 (Stop)

# Download the latest version
wget -O network3.sh https://raw.githubusercontent.com/Galkurta/network3/main/network3.sh

# Make executable
chmod +x network3.sh

# Start the node
./network3.sh
# Select option 2 (Start)
```

## License

This script is provided under the MIT license.

## Author

Created by Galkurta  
GitHub: [https://github.com/Galkurta](https://github.com/Galkurta)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Disclaimer

This is an unofficial installation guide. Use at your own risk. Always verify scripts before running them on your system.

## Security Recommendations

1. Always run the node with a dedicated user
2. Keep your system updated
3. Use strong firewall rules
4. Monitor your system regularly
5. Backup your API keys
6. Never share your private keys
