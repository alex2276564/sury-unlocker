# ⚠️ Warning: This project has not been thoroughly tested. Use at your own risk. I'll finalize it later. ⚠️


# Sury Unlocker Script 🌐💡  
[![Linux Distributions](https://img.shields.io/badge/Linux-Debian%20%7C%20Ubuntu-blue)](https://www.debian.org/)  
[![Bash Compatible](https://img.shields.io/badge/Bash-Compatible-green)](https://www.gnu.org/software/bash/)  
[![Version 1.0](https://img.shields.io/badge/Version-1.0-blue.svg)](https://github.com/alex2276564/sury-unlocker)  
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)  

**Sury Unlocker Script** is a Bash solution to bypass IP restrictions for `packages.sury.org` using OpenVPN with split-tunneling. This script is designed to work seamlessly on Debian-based Linux distributions. It supports Docker integration and allows you to easily enable or disable OpenVPN with custom configurations.

---

## ⚠️ WARNING: This script will NOT work for local development on your personal computer in Russia.  
### This is because Roskomnadzor (Russia's internet regulator) blocks VPN protocols, and the one used here is likely also blocked.  
### The script is intended for use on servers located in Russia.  
### If you need a solution for local development in Russia, consider using HLVPN instead: [https://t.me/s/highloadofficial](https://t.me/s/highloadofficial).

---

## ✨ Features

- ✅ **Automated Setup:** Automatically installs and configures OpenVPN and DNS utilities if they are not installed.  
- ✅ **Split-Tunneling Support:** Routes only traffic to `packages.sury.org` through the VPN, leaving other traffic unaffected.  
- ✅ **Custom Configuration:** Specify a custom `.ovpn` file for OpenVPN using the `-path` option.  
- ✅ **Docker Compatibility:** Easily integrate this script into Dockerfiles for automated environments.  
- ✅ **Convenient Management:** Provide options to enable or disable the OpenVPN daemon.  
- ✅ **Sury Repository Installation:** Option to install Sury repositories when VPN is enabled.

---

## 📥 Installation

### Prerequisites

1. **Supported Linux Distributions:**  
   - Debian-based (e.g., Ubuntu, Debian).  

2. **OpenVPN Configuration File:** 
   - Obtain a `.ovpn` file for your NOT RUSSIA VPN provider.
   - You can get free OpenVPN configurations from [FreeOpenVPN.org](https://www.freeopenvpn.org/). **Ensure you use TCP servers.**
   - Place the `.ovpn` file in the same directory as the script.

---

### Installation Steps

1. **Clone the Repository:**  
   ```bash
   apt update && \
   apt install git -y && \
   git clone https://github.com/alex2276564/sury-unlocker.git && \
   cd sury-unlocker
   ```

2. **Make the Script Executable:**  
   ```bash
   chmod +x sury-unlocker.sh
   ```

3. **Run the Script:**  
   ```bash
   ./sury-unlocker.sh
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

### Custom OpenVPN Configuration

Specify a custom `.ovpn` file with the `-path` option:  
```bash
./sury-unlocker.sh -path=/path/to/your/custom.ovpn
```

### Disable OpenVPN

If you want to stop the OpenVPN daemon, use the `-disableovpn` option:  
```bash
./sury-unlocker.sh -disableovpn
```

### Install Sury Repositories

To install Sury repositories using the official installer (use only when VPN is enabled):
```bash
./sury-unlocker.sh -addsuryrepositories
```

---

## 🐳 Docker Integration

You can include the **Sury Unlocker Script** in your `Dockerfile` to bypass the Sury.org block when building or running containerized applications. Before you begin, in this example make sure to place your `custom.ovpn` file (the OpenVPN configuration file) in the same directory as the `Dockerfile`. This file will be copied into the container during the build process.


### Important Note for Debian/Ubuntu Host Systems:
If you are running a **Debian** or **Ubuntu** based host system, you can run the script directly on the host. Once the VPN is activated on the host, all Docker containers will automatically use the VPN connection through the host network.


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
# Make sure you've placed the 'custom.ovpn' file in the same directory as this Dockerfile
COPY custom.ovpn /opt/sury-unlocker/custom.ovpn

# Run the Sury unlocker script with the custom OpenVPN config
RUN ./sury-unlocker.sh -path=/opt/sury-unlocker/custom.ovpn

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

## 🖥️ Compatibility

- **Distributions:** Debian-based Linux (e.g., Debian, Ubuntu).
- **Docker Compatibility:** Fully supported.
- **OpenVPN Configuration:** Supports all standard `.ovpn` files.
- **Sury Repositories:** Official installer integrated for seamless setup.

---

## 🌐 How It Works

This script follows these steps:

1. **Dependency Check**  
   The script verifies if the required tools (`openvpn` and `dnsutils`) are installed. If not, it automatically installs them on the system.  

2. **Resolve IP Address**  
   The script resolves the IPv4 address of `packages.sury.org` using the `nslookup` command. This ensures that the latest IP is always used, even if it changes.  

3. **Modify OpenVPN Configuration**  
   It appends the following to the provided `.ovpn` file to enable split-tunneling:  
   - `route-nopull`: Prevents the VPN from routing all traffic.  
   - A specific route for the resolved IP of `packages.sury.org`.  

4. **Start OpenVPN Daemon**  
   The script launches the OpenVPN daemon in the background with the modified configuration. This allows traffic to `packages.sury.org` to be routed through the VPN while leaving other traffic unaffected.  

5. **Sury Repository Installation**  
   When the `-addsuryrepositories` option is used, the script employs the official Sury repository installer to add the repositories to your system.

6. **Disable Option**  
   The script also provides a `-disableovpn` option to stop the OpenVPN daemon, restoring normal network behavior.  

---

## 🆘 Troubleshooting

### Common Issues
1. **OpenVPN Fails to Start**  
   - Ensure your `.ovpn` file is valid and properly configured.  
   - Check the logs for errors using:  
     ```bash
     journalctl -u openvpn
     ```

2. **Cannot Resolve `packages.sury.org`**  
   - Ensure DNS utilities `dnsutils` are installed.  
   - Verify your network connectivity.  

3. **VPN Server Issues**  
   - If the VPN server is overloaded or not responding, try another `.ovpn` file for example from [FreeOpenVPN.org](https://www.freeopenvpn.org/).  

---

## 📋 Requirements

- **Linux Distributions:**  
  - Debian-based (e.g., Debian, Ubuntu).  

- **Dependencies:**  
  - `openvpn` for VPN connectivity.  
  - `dnsutils` for DNS resolution.  

- **OpenVPN Configuration:**  
  - A valid `.ovpn` file from your VPN provider.  

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