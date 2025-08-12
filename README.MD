# Sury Unlocker Script 🌐💡

[![Linux Distributions](https://img.shields.io/badge/Linux-Debian%20%7C%20RHEL-blue)](https://www.debian.org/)
[![Bash Compatible](https://img.shields.io/badge/Bash-Compatible-green)](https://www.gnu.org/software/bash/)
[![Version 1.0](https://img.shields.io/badge/Version-1.0-blue.svg)](https://github.com/alex2276564/sury-unlocker)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

[🇷🇺 Руководство на русском](README.ru.md)

**Sury Unlocker Script** is a Bash solution created in response to the [July 2024 geo-blocking](https://github.com/oerdnj/deb.sury.org/issues/2155) of `packages.sury.org` for Russian IP addresses. When Ondřej Surý implemented geo-restrictions for his PHP PPA repositories in Russia, this script was developed to provide a legitimate way to access these essential development resources. It uses OpenVPN with split-tunneling to bypass IP restrictions, supporting both Debian-based and RHEL-based distributions. While Sury repositories are only available for Debian-based systems, the script can be used in both host systems and Docker containers regardless of the host OS. Features VPN authentication support and comprehensive repository management tools.

## ⚠️ WARNING: This script will NOT work for local development on your personal computer in Russia

### This is because Roskomnadzor (Russia's internet regulator) blocks VPN protocols, and the one used here is likely also blocked

### The script is intended for use on servers located in Russia

### If you need a solution for local development in Russia, consider using HLVPN instead: <https://t.me/s/highloadofficial>

## ✨ Features

- ✅ **Multi-distribution Support:**
  - **Debian-based Systems:** Full support with Sury repositories installation (Debian, Ubuntu, Linux Mint, etc.)
  - **RHEL-based Systems:** Work as VPN tunnel proxy hosts. Perfect for running Docker containers with Debian/Sury
- ✅ **Flexible Deployment:**
  - RHEL host systems can run Docker containers with Debian and Sury repositories
  - VPN tunnel on the host automatically works for all containers
- ✅ **Automatic Configuration:** Automatically installs and configures OpenVPN and DNS utilities
- ✅ **Split-tunneling:** Routes only specific traffic through VPN
- ✅ **Custom Configuration Support:**
  - Support for custom `.ovpn` files
  - Authentication-enabled VPN servers support (username/password)
- ✅ **Sury Repository Management:**
  - Official method repository installation
  - Complete repository cleanup capability when needed

## 📥 Installation and Prerequisites

### System Requirements

- **Supported Host Systems:**
  - Any Linux distribution (Debian-based or RHEL-based). **RHEL-based systems are intended for proxying traffic to packages.sury.org, primarily for running Docker containers with PHP Sury.**
- **For Sury Repositories:**
  - Must use a Debian-based system (either host or container)
- **Docker (Optional):**
  - Supported on any host OS for containerized environments

### OpenVPN Configuration

1. Obtain a `.ovpn` file for your NOT RUSSIA VPN provider.
2. You can get free OpenVPN configurations from [FreeOpenVPN.org](https://www.freeopenvpn.org/). **Ensure you use TCP servers.**
3. Place the `.ovpn` file in the same directory as the script.

### Installation Steps

1. **Clone the repository:**

   For Debian-based systems:

   ```bash
   apt install git -y && \
   git clone https://github.com/alex2276564/sury-unlocker.git && \
   cd sury-unlocker
   ```

   For RHEL-based systems:

   ```bash
   yum install git -y && \
   git clone https://github.com/alex2276564/sury-unlocker.git && \
   cd sury-unlocker
   ```

2. **Prepare OpenVPN configuration:**
   - Place your `.ovpn` file in the `sury-unlocker` directory.
   - The file name can be anything, as long as it's in the same folder as the script.

3. **Make the script executable:**

   ```bash
   chmod +x sury-unlocker.sh
   ```

4. **Run the script:**
   - With default settings:

   ```bash
   ./sury-unlocker.sh
   ```

   - Or with a custom `.ovpn` filename:

   ```bash
   ./sury-unlocker.sh -path=your_custom_name.ovpn
   ```

5. **Delete Sury repositories (optional):**
   - If you encounter an error with `apt update` after the blocking, use this command to delete Sury repositories:

   ```bash
   ./sury-unlocker.sh -deletesuryrepositories
   ```

6. **Add Sury repositories using the official method:**

   ```bash
   ./sury-unlocker.sh -addsuryrepositories
   ```

   - If you encounter an error when running the `addsuryrepositories` command, try the following:
     - Terminate the current VPN connection using the `disableovpn` command:

       ```bash
       ./sury-unlocker.sh -disableovpn
       ```

     - Delete the old `.ovpn` file from the current directory if you didn't use the `-path` option.
     - Find a new free VPN server, for example, at [FreeOpenVPN.org](https://www.freeopenvpn.org/) or [OpenTunnel.net](https://opentunnel.net/openvpn/).
     - Reconnect to the VPN using the new `.ovpn` file, and try adding the Sury repositories again. Repeat these steps until the repositories are added successfully.

7. **Install the desired PHP:**
   - After successfully adding the Sury repositories, you can install the desired version of PHP, for example:

   ```bash
   apt install php7.4
   ```

   - Please note that installing PHP is only possible while the VPN connection is active. If the VPN disconnects, you will need to reconnect using a new VPN server and try again.

## 🛠️ Usage

Before running the script, ensure that your `.ovpn` file is in the same directory as the script.

This script provides several options for customizing its behavior. Here's how you can use it:

### View Help

To see all available options and their descriptions:

```bash
./sury-unlocker.sh -help
```

### Basic Usage

Run the script without any arguments to automatically configure OpenVPN with split-tunneling for `packages.sury.org`:

```bash
./sury-unlocker.sh
```

### (Optional) Custom OpenVPN Configuration

Specify a custom `.ovpn` file with the `-path` option:

```bash
./sury-unlocker.sh -path=/path/to/your/your_custom_name.ovpn
```

### (Optional) Provide VPN Credentials

If your VPN requires authentication, you can provide the username and password:

```bash
./sury-unlocker.sh -username=your_username -password=your_password
```

### Install Sury Repositories

To install Sury repositories using the official installer (only for Debian-based systems or Debian-based Docker containers, use only when VPN is enabled):

```bash
./sury-unlocker.sh -addsuryrepositories
```

### Delete Sury Repositories

To remove Sury repositories and related files from your system, use the `-deletesuryrepositories` option:

```bash
./sury-unlocker.sh -deletesuryrepositories
```

### Disable OpenVPN

If you want to stop the OpenVPN daemon, use the `-disableovpn` option:

```bash
./sury-unlocker.sh -disableovpn
```

## 🐳 Docker Integration

You can include the **Sury Unlocker Script** in your `Dockerfile` to bypass the Sury.org block when building or running containerized applications. Before you begin, in this example make sure to place your `your_custom_name.ovpn` file (the OpenVPN configuration file) in the same directory as the `Dockerfile`. This file will be copied into the container during the build process.

### Important Notes

1. To run OpenVPN inside a container, you need to grant additional privileges to the container. You can do this in two ways:

   Using docker run:

   ```bash
   docker run --cap-add=NET_ADMIN --device=/dev/net/tun:/dev/net/tun your-image-name
   ```

   Using docker-compose.yml:

   ```yaml
   services:
     your-service:
       build: .
       cap_add:
         - NET_ADMIN
       devices:
         - /dev/net/tun:/dev/net/tun
   ```

2. For Debian/RHEL Host Systems:
   If you are running a **Debian** or **RHEL** based host system, you can run the script directly on the host. Once the VPN is activated on the host, all Docker containers will automatically use the VPN connection through the host network.

3. In the Dockerfile example below, OpenVPN will only be active during the build phase (when installing PHP 7.4). After container startup, the VPN connection will not be established automatically.

### Dockerfile Example

```dockerfile
FROM debian:latest

# Update and install dependencies for the Sury unlocker script
# These are needed to run the script and manage OpenVPN
RUN apt-get update && apt-get install -y \
    git \
    openvpn \
    dnsutils

# Clone and set up the Sury unlocker script
RUN git clone https://github.com/alex2276564/sury-unlocker.git /opt/sury-unlocker
WORKDIR /opt/sury-unlocker
RUN chmod +x sury-unlocker.sh

# Copy the custom .ovpn file into the container
COPY your_custom_name.ovpn /opt/sury-unlocker/your_custom_name.ovpn

# Run the Sury unlocker script with the custom OpenVPN config
RUN ./sury-unlocker.sh -path=/opt/sury-unlocker/your_custom_name.ovpn

# Install Sury repositories using the official installer integrated into the script
RUN ./sury-unlocker.sh -addsuryrepositories

# Install PHP 7.4 (or any other package from Sury)
RUN apt-get install -y php7.4
```

Note: Without proper container privileges (NET_ADMIN capability and TUN device access), OpenVPN will not work inside the container. Make sure to run your container with the necessary privileges as shown in the examples above.

## 🌐 How it works

The script performs the following steps:

1. **OS Detection and Dependency Check**
   - Identifies the operating system (Debian-based, RHEL-based, or other supported system)
   - Checks for and installs required tools if needed:
     - `openvpn` for VPN connectivity
     - `dnsutils` (Debian) or `bind-utils` (RHEL) for DNS operations

2. **IP Address Resolution**
   Uses `nslookup` to determine the IPv4 address of `packages.sury.org`, ensuring the correct IP is used even if it changes

3. **VPN Authentication Processing**
   - Checks for username/password parameters
   - Creates temporary authentication file when credentials are provided
   - Automatically integrates credentials into OpenVPN configuration

4. **OpenVPN Configuration Modification**
   Modifies the provided `.ovpn` file to enable split-tunneling:
   - `route-nopull`: prevents routing all traffic through VPN
   - Adds route only for `packages.sury.org` IP address

5. **OpenVPN Daemon Management**
   Launches OpenVPN daemon in background with modified configuration, routing only specific traffic through VPN

6. **Sury Repository Management (Debian-based systems only)**
   When using respective options:
   - `-addsuryrepositories`: installs repositories using official installer
   - `-deletesuryrepositories`: completely removes all Sury repository files
   - Automatically verifies system compatibility before operations

7. **VPN Connection Control**
   - `-disableovpn`: properly stops OpenVPN processes
   - Automatically cleans up authentication temporary files
   - Restores default network behavior

## 🆘 Troubleshooting

### Common Issues

1. **OpenVPN Fails to Start**
   - Verify `.ovpn` file validity and configuration
   - Check system logs:

     ```bash
     # For systemd-based systems
     journalctl -u openvpn
     
     # For general OpenVPN logs
     tail -f /var/log/openvpn.log
     ```

2. **VPN Connection Problems**
   - Ensure the VPN server is accessible
   - Try TCP-based `.ovpn` configurations
   - Consider alternative `.ovpn` files from [FreeOpenVPN.org](https://www.freeopenvpn.org/) or [OpenTunnel.net](https://opentunnel.net/openvpn/)

## 🆘 Support

If you encounter any issues or have suggestions for improving the plugin, please create an [issue](https://github.com/alex2276564/sury-unlocker/issues) in this repository.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

[Alex] - [https://github.com/alex2276564]

We appreciate your contribution to the project! If you like this plugin, please give it a star on GitHub.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/alex2276564/sury-unlocker/issues).

### How to Contribute

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/YourFeature`).
3. Commit your changes (`git commit -m 'Add some feature'`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Open a Pull Request.

---

Thank you for using the **Sury Unlocker Script**! We hope it helps you to bypass the Sury.org block for OpenVPN. 🚀🔓🌐
