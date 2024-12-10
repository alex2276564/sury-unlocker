#!/bin/bash

# Script Name: sury-unlocker.sh
# Description: Bypass IP restrictions for packages.sury.org using OpenVPN split-tunneling
# Author: alex2276564
# Github: https://github.com/alex2276564/sury-unlocker
# Version: 1.0
# License: MIT

# Exit on error
set -e

# Function to print usage information
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -path=file.ovpn      Specify a custom OpenVPN configuration file."
    echo "  -disableovpn         Disable OpenVPN daemon if running."
    echo "  -addsuryrepositories Install Sury repositories (Debian-based systems only)."
    echo "  -help                Display this help message."
}

# Function to detect the OS family (Debian or RHEL)
detect_os_family() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
        debian | ubuntu | linuxmint | elementary | kali | parrot | deepin | pop | neon | zorin)
            echo "debian"
            ;;
        rhel | centos | fedora | rocky | almalinux | oracle | scientific | amazon | redhat | alma | ol)
            echo "rhel"
            ;;
        *)
            echo "unknown"
            ;;
        esac
    else
        echo "unknown"
    fi
}

# Function to install a package if not already installed (Debian or RHEL)
install_package() {
    local package=$1
    local os_family=$2

    if [ "$os_family" = "debian" ]; then
        echo "Installing $package on Debian-based system..."
        sudo apt update && sudo apt install -y "$package"
    elif [ "$os_family" = "rhel" ]; then
        echo "Installing $package on RHEL-based system..."
        sudo yum install -y "$package" # dnf is not used for compatibility with legacy systems
    else
        echo "Unsupported OS."
        exit 1
    fi
}

# Function to configure and start OpenVPN
configure_openvpn() {
    local ovpn_file="$1"
    local target_ip="$2"

    echo "Configuring OpenVPN for split tunneling..."

    # Check if route-nopull is already in the file
    if ! grep -q "route-nopull" "$ovpn_file"; then
        echo -e "\n# Split-Tunneling: Prevent pulling default routes\nroute-nopull" >>"$ovpn_file"
        echo "Added route-nopull to the OpenVPN configuration file."
    fi

    # Check if the target_ip is already in the file
    if grep -q "route $target_ip 255.255.255.255" "$ovpn_file"; then
        echo "The target_ip is already configured in the OpenVPN file. No changes needed."
    else
        # Replace the existing target_ip if it exists
        sed -i "/route [0-9.]* 255.255.255.255/c\\route $target_ip 255.255.255.255" "$ovpn_file"
        echo "Updated target_ip in the OpenVPN configuration file."
    fi

    # Start the OpenVPN daemon
    sudo systemctl start openvpn || true
    sudo openvpn --config "$ovpn_file" --daemon
    echo "OpenVPN configured and started. Verify access to packages.sury.org."
}

# Function to disable OpenVPN daemons and processes
disable_openvpn() {
    echo "Disabling OpenVPN..."

    if systemctl is-active --quiet openvpn; then
        echo "Stopping OpenVPN service..."
        sudo systemctl stop openvpn || true
    else
        echo "OpenVPN service is not running."
    fi

    # Find all manually started OpenVPN processes and terminate them
    openvpn_pids=$(pgrep openvpn)
    if [ -n "$openvpn_pids" ]; then
        echo "Killing manually started OpenVPN processes..."
        sudo kill $openvpn_pids || true

        # Check if there are any processes left and force termination if necessary
        sleep 2
        openvpn_pids_remaining=$(pgrep openvpn)
        if [ -n "$openvpn_pids_remaining" ]; then
            echo "Forcing termination of remaining OpenVPN processes..."
            sudo kill -9 $openvpn_pids_remaining || true
        fi
    else
        echo "No manually started OpenVPN processes found."
    fi

    echo "OpenVPN disabled."
}

# Function to install Sury repositories (only for Debian-based systems)
install_sury_repositories() {
    local os_family=$1

    if [ "$os_family" != "debian" ]; then
        echo "Sury repositories can only be installed on Debian-based systems. Skipping."
        exit 0
    fi

    echo "Installing Sury repositories on Debian-based system using the official installer.."

    if [ "$(whoami)" != "root" ]; then
        SUDO=sudo
    fi

    ${SUDO} apt-get update
    ${SUDO} apt-get -y install lsb-release ca-certificates curl
    ${SUDO} curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb
    ${SUDO} dpkg -i /tmp/debsuryorg-archive-keyring.deb
    ${SUDO} sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
    ${SUDO} apt-get update

    echo "Sury repositories installed successfully using the official method."
}

# Main script logic

# Parse command-line arguments
custom_ovpn=""
disable_ovpn=false
add_sury_repos=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
    -path=*) custom_ovpn="${1#*=}" ;;
    -disableovpn) disable_ovpn=true ;;
    -addsuryrepositories) add_sury_repos=true ;;
    -help)
        usage
        exit 0
        ;;
    *)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
    shift
done

# Detect OS family
os_family=$(detect_os_family)

if [ "$os_family" = "unknown" ]; then
    echo "Unsupported or unknown OS. Exiting."
    exit 1
fi

if $disable_ovpn; then
    disable_openvpn
    exit 0
fi

if $add_sury_repos; then
    install_sury_repositories "$os_family"
    exit 0
fi

# Check and install required packages
if ! command -v openvpn &>/dev/null; then
    install_package openvpn "$os_family"
fi

if ! command -v nslookup &>/dev/null; then
    if [ "$os_family" = "debian" ]; then
        install_package dnsutils "$os_family"
    elif [ "$os_family" = "rhel" ]; then
        install_package bind-utils "$os_family"
    fi
fi

# Resolve the IPv4 address of the target site (replace with packages.sury.org if needed)
target_site="packages.sury.org"
echo "Resolving IPv4 address for $target_site..."
target_ip=$(nslookup -type=A $target_site | awk '/^Address: / { print $2; exit }')

if [[ -z "$target_ip" ]]; then
    echo "Failed to resolve IPv4 address for $target_site. Exiting."
    exit 1
fi

echo "Resolved IPv4: $target_ip"

# Check for custom OpenVPN file or default to a file in the script's directory
if [[ -n "$custom_ovpn" ]]; then
    ovpn_file="$custom_ovpn"
else
    script_dir=$(dirname "$0")
    ovpn_files=($script_dir/*.ovpn)
    if [[ ${#ovpn_files[@]} -eq 0 ]]; then
        echo "No .ovpn file found in the script's directory."
        echo "Please provide a valid .ovpn file or use the -path option."
        exit 1
    elif [[ ${#ovpn_files[@]} -gt 1 ]]; then
        echo "Multiple .ovpn files found in the script's directory. Please specify one using the -path option."
        exit 1
    else
        ovpn_file=${ovpn_files[0]}
    fi
fi

if [[ ! -f "$ovpn_file" ]]; then
    echo "OpenVPN configuration file not found: $ovpn_file"
    echo "Please provide a valid .ovpn file or use the -path option."
    exit 1
fi

# Configure OpenVPN and start the daemon
configure_openvpn "$ovpn_file" "$target_ip"
