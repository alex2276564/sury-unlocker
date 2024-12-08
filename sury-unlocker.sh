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
    echo "  -addsuryrepositories Install Sury repositories using the official installer (use only when VPN is enabled)."
    echo "  -help                Display this help message."
}

# Function to install a package if not already installed
install_package() {
    local package=$1

    echo "Installing $package..."
    sudo apt update && sudo apt install -y "$package"
}

# Function to configure and start OpenVPN
configure_openvpn() {
    local ovpn_file="$1"
    local sury_ip="$2"

    echo "Configuring OpenVPN for split tunneling..."

    # Check if route-nopull is already in the file
    if ! grep -q "route-nopull" "$ovpn_file"; then
        echo -e "\n# Split-Tunneling: Prevent pulling default routes\nroute-nopull" >>"$ovpn_file"
        echo "Added route-nopull to the OpenVPN configuration file."
    fi

    # Check if the sury_ip is already in the file
    if grep -q "route $sury_ip 255.255.255.255" "$ovpn_file"; then
        echo "The sury_ip is already configured in the OpenVPN file. No changes needed."
    else
        # Replace the existing sury_ip if it exists
        sed -i "/route [0-9.]* 255.255.255.255/c\\route $sury_ip 255.255.255.255" "$ovpn_file"
        echo "Updated sury_ip in the OpenVPN configuration file."
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

# Function to install Sury repositories (official installer is used)
install_sury_repositories() {
    echo "Installing Sury repositories using the official installer..."

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

if $disable_ovpn; then
    disable_openvpn
    exit 0
fi

if $add_sury_repos; then
    install_sury_repositories
    exit 0
fi

# Check and install required packages
if ! command -v openvpn &>/dev/null; then
    install_package openvpn
fi

if ! command -v nslookup &>/dev/null; then
    install_package dnsutils
fi

# Resolve the IPv4 address of packages.sury.org
echo "Resolving IPv4 address for packages.sury.org..."
sury_ip=$(nslookup -type=A packages.sury.org | awk '/^Address: / { print $2; exit }')

if [[ -z "$sury_ip" ]]; then
    echo "Failed to resolve IPv4 address for packages.sury.org. Exiting."
    exit 1
fi

echo "Resolved IPv4: $sury_ip"

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
configure_openvpn "$ovpn_file" "$sury_ip"
