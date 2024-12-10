# ⚠️ Warning: This project has not been thoroughly tested. Use at your own risk. I'll finalize it later. ⚠️


# Sury Unlocker Script 🌐💡  
[![Linux Distributions](https://img.shields.io/badge/Linux-Debian%20%7C%20RHEL-blue)](https://www.debian.org/)  
[![Bash Compatible](https://img.shields.io/badge/Bash-Compatible-green)](https://www.gnu.org/software/bash/)  
[![Version 1.0](https://img.shields.io/badge/Version-1.0-blue.svg)](https://github.com/alex2276564/sury-unlocker)  
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)  

**Sury Unlocker Script** is a Bash solution created in response to the July 2024 geo-blocking of `packages.sury.org` for Russian IP addresses. When Ondřej Surý implemented geo-restrictions for his PHP PPA repositories in Russia, this script was developed to provide a legitimate way to access these essential development resources. It uses OpenVPN with split-tunneling to bypass IP restrictions, supporting both Debian-based and RHEL-based distributions. While Sury repositories are only available for Debian-based systems, the script can be used in both host systems and Docker containers regardless of the host OS.

---

## ⚠️ WARNING: This script will NOT work for local development on your personal computer in Russia.  
### This is because Roskomnadzor (Russia's internet regulator) blocks VPN protocols, and the one used here is likely also blocked.  
### The script is intended for use on servers located in Russia.  
### If you need a solution for local development in Russia, consider using HLVPN instead: [https://t.me/s/highloadofficial](https://t.me/s/highloadofficial).

---

## ✨ Features

- ✅ **Multi-Distribution Support:** Works on both Debian and RHEL-based systems
- ✅ **Wide Distribution Compatibility:** Supports various Linux distributions:
  - Debian-based: Debian, Ubuntu, Linux Mint, Elementary OS, Kali Linux, Parrot OS, Deepin, Pop!_OS, KDE Neon, Zorin OS
  - RHEL-based: RHEL, CentOS, Fedora, Rocky Linux, AlmaLinux, Oracle Linux, Scientific Linux, Amazon Linux
- ✅ **Flexible Deployment:** Works both on host systems and in Docker containers
- ✅ **Automated Setup:** Automatically installs and configures OpenVPN and DNS utilities
- ✅ **Split-Tunneling Support:** Routes only specific traffic through the VPN
- ✅ **Custom Configuration:** Specify custom `.ovpn` files
- ✅ **Sury Repository Support:** Install Sury repositories on Debian-based systems

---

## 📥 Installation and Prerequisites

### System Requirements
- **Supported Host Systems:** 
  - Any Linux distribution (Debian-based or RHEL-based)
- **For Sury Repositories:** 
  - Must use a Debian-based system (either host or container)
- **Docker (Optional):** 
  - Supported on any host OS for containerized environments

### OpenVPN Configuration
1. Obtain a `.ovpn` file for your NOT RUSSIA VPN provider.
2. You can get free OpenVPN configurations from [FreeOpenVPN.org](https://www.freeopenvpn.org/). **Ensure you use TCP servers.**
3. Place the `.ovpn` file in the same directory as the script.

### Installation Steps
1. **Clone the Repository:**  
   ```bash
   apt update && \
   apt install git -y && \
   git clone https://github.com/alex2276564/sury-unlocker.git && \
   cd sury-unlocker
   ```

2. **Prepare OpenVPN Configuration:**
   - Place your `.ovpn` file in the `sury-unlocker` directory.
   - The file can have any name, as long as it's in the same directory as the script

3. **Make the Script Executable:**  
   ```bash
   chmod +x sury-unlocker.sh
   ```

4. **Run the Script:**
   - With default configuration:
   ```bash
   ./sury-unlocker.sh
   ```
   - Or with a custom OpenVPN file name:
   ```bash
   ./sury-unlocker.sh -path=your_custom_name.ovpn
   ```

---

## 🛠️ Usage

Before running the script, ensure that your `.ovpn` file is in the same directory as the script.

This script provides several options for customizing its behavior. Here's how you can use it:

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

### Install Sury Repositories

To install Sury repositories using the official installer (only for Debian-based systems or Debian-based Docker containers, use only when VPN is enabled):
```bash
./sury-unlocker.sh -addsuryrepositories
```

### Disable OpenVPN

If you want to stop the OpenVPN daemon, use the `-disableovpn` option:  
```bash
./sury-unlocker.sh -disableovpn
```

---

## 🐳 Docker Integration

You can include the **Sury Unlocker Script** in your `Dockerfile` to bypass the Sury.org block when building or running containerized applications. Before you begin, in this example make sure to place your `your_custom_name.ovpn` file (the OpenVPN configuration file) in the same directory as the `Dockerfile`. This file will be copied into the container during the build process.


### Important Note for Debian/RHEL Host Systems:
If you are running a **Debian** or **RHEL** based host system, you can run the script directly on the host. Once the VPN is activated on the host, all Docker containers will automatically use the VPN connection through the host network.


---

#### Enabling OpenVPN and Installing Sury Repositories in Docker:

If you prefer to run the VPN inside the container, use the following `Dockerfile` example:  
```Dockerfile
FROM debian:latest

# Update and install dependencies for the Sury unlocker script
# These are needed to run the script and manage OpenVPN
RUN apt-get update && apt-get install -y \
    git \
    openvpn \
    dnsutils \
    sudo

# Clone and set up the Sury unlocker script
RUN git clone https://github.com/alex2276564/sury-unlocker.git /opt/sury-unlocker
WORKDIR /opt/sury-unlocker
RUN chmod +x sury-unlocker.sh

# Copy the custom .ovpn file into the container
# Make sure you've placed the 'your_custom_name.ovpn' file in the same directory as this Dockerfile
COPY your_custom_name.ovpn /opt/sury-unlocker/your_custom_name.ovpn

# Run the Sury unlocker script with the custom OpenVPN config
RUN ./sury-unlocker.sh -path=/opt/sury-unlocker/your_custom_name.ovpn

# Install Sury repositories using the official installer integrated into the script
RUN ./sury-unlocker.sh -addsuryrepositories

# The following lines are commented out because they are now automatically handled by the script when using `./sury-unlocker.sh -addsuryrepositories`.
# The script performs the equivalent actions internally to add the Sury PHP repository.
#
# # Install dependencies for adding the Sury repository
# # These packages are necessary to add and manage the Sury PHP repository
# RUN apt-get install -y \
#     lsb-release \
#     ca-certificates \
#     curl
#
# # Add Sury's repository using the official installation method
# RUN curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb && \
#     dpkg -i /tmp/debsuryorg-archive-keyring.deb && \
#     sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' && \
#     apt-get update

# Install PHP 7.4 (or any other package from Sury)
RUN apt-get install -y php7.4

# (Optional) Disable OpenVPN if not needed later in the container lifecycle
# RUN /opt/sury-unlocker/sury-unlocker.sh -disableovpn

# ... rest of your Dockerfile ...
```

---

## 🌐 How It Works

This script follows these steps:

1. **OS Detection and Dependency Check**  
   - Detects the operating system (Debian-based, RHEL-based, or other supported systems)
   - Verifies and installs required tools:
     - `openvpn` for VPN connectivity
     - `dnsutils` (Debian) or `bind-utils` (RHEL) for DNS resolution

2. **Resolve IP Address**  
   The script resolves the IPv4 address of `packages.sury.org` using the `nslookup` command, ensuring the latest IP is always used, even if it changes.

3. **Modify OpenVPN Configuration**  
   Modifies the provided `.ovpn` file to enable split-tunneling:  
   - `route-nopull`: Prevents the VPN from routing all traffic
   - Adds a specific route for the resolved IP of `packages.sury.org`

4. **Start OpenVPN Daemon**  
   Launches the OpenVPN daemon in the background with the modified configuration, routing only specific traffic through the VPN while leaving other traffic unaffected.

5. **Sury Repository Installation (Debian-based systems only)**  
   When using `-addsuryrepositories` on a Debian-based system, the script:
   - Verifies the system is Debian-based
   - Uses the official Sury repository installer
   - Configures the repository with proper GPG keys and sources

6. **Disable Option**  
   Provides `-disableovpn` to stop the OpenVPN daemon and clean up processes, restoring normal network behavior.

---

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

2. **DNS Resolution Issues**  
   - For Debian-based systems:
     ```bash
     sudo apt install dnsutils
     ```
   - For RHEL-based systems:
     ```bash
     sudo yum install bind-utils
     ```
   - Verify network connectivity
   - Try alternative DNS servers

3. **VPN Connection Problems**  
   - Ensure the VPN server is accessible
   - Try TCP-based `.ovpn` configurations
   - Consider alternative `.ovpn` files from [FreeOpenVPN.org](https://www.freeopenvpn.org/)

4. **Sury Repository Installation Fails**  
   - Verify you're using a Debian-based system
   - Check internet connectivity through VPN:
     ```bash
     ping packages.sury.org
     ```
   - Ensure proper GPG key installation

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

[Alex] - [https://github.com/alex2276564] 

If you enjoy this project or find it useful, consider giving it a ⭐ on GitHub!

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome. Please feel free to check the issues page.

### How to Contribute

1. **Fork the repository.**
2. **Create a new branch (`git checkout -b feature/YourFeature`).**
3. **Commit your changes (`git commit -m 'Add some feature').**
4. **Push to the branch (`git push origin feature/YourFeature`).**
5. **Open a Pull Request.**

---

Thank you for using the Sury Unlocker Script! We hope it helps you to bypass the Sury.org block for OpenVPN. 🚀🔓🌐