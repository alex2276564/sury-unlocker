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
    echo "  -deletesuryrepositories Remove Sury repositories and related files."
    echo "  -username=<username> Specify the OpenVPN username (optional)."
    echo "  -password=<password> Specify the OpenVPN password (optional)."
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
        $SUDO apt update && $SUDO apt install -y "$package"
    elif [ "$os_family" = "rhel" ]; then
        echo "Installing $package on RHEL-based system..."
        $SUDO yum install -y "$package"
    else
        echo "Unsupported OS."
        exit 1
    fi
}

# Function to delete Sury repositories
delete_sury_repositories() {
    local os_family=$1

    if [ "$os_family" != "debian" ]; then
        echo "Sury repositories can only be deleted on Debian-based systems. Skipping."
        exit 0
    fi

    echo "Deleting Sury repositories..."

    # Remove repository file
    if [ -f /etc/apt/sources.list.d/php.list ]; then
        echo "Removing PHP repository file..."
        $SUDO rm -f /etc/apt/sources.list.d/php.list
    fi

    # Remove keyring files
    echo "Removing keyring files..."
    $SUDO rm -f /usr/share/keyrings/deb.sury.org-php.gpg
    $SUDO rm -f /etc/apt/trusted.gpg.d/php.gpg

    # Remove the debsuryorg-archive-keyring package if installed
    if dpkg -l | grep -q debsuryorg-archive-keyring; then
        echo "Removing debsuryorg-archive-keyring package..."
        $SUDO apt-get remove -y debsuryorg-archive-keyring
    fi

    # Update package lists
    echo "Updating package lists..."
    $SUDO apt-get update

    echo "Sury repositories deleted successfully."
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
        echo "Adding new route to the OpenVPN configuration file..."
        echo "route $target_ip 255.255.255.255" >>"$ovpn_file"
    fi

    # Start OpenVPN as a daemon
    echo "Starting OpenVPN..."
    $SUDO openvpn --config "$ovpn_file" --daemon
    echo "OpenVPN configured and started. Verify access to packages.sury.org."
}

# Function to disable OpenVPN daemons and processes
disable_openvpn() {
    echo "Disabling OpenVPN..."

    # Try to stop OpenVPN using systemctl or service
    if command -v systemctl &>/dev/null && systemctl is-active --quiet openvpn; then
        echo "Stopping OpenVPN service with systemctl..."
        $SUDO systemctl stop openvpn || true
    elif command -v service &>/dev/null; then
        echo "Stopping OpenVPN service with service..."
        $SUDO service openvpn stop || true
    else
        echo "Systemctl and service are unavailable. Skipping service stop."
    fi

    # Kill any remaining OpenVPN processes manually
    echo "Checking for remaining OpenVPN processes..."
    openvpn_pids=$(pgrep openvpn)
    if [ -n "$openvpn_pids" ]; then
        echo "Killing manually started OpenVPN processes..."
        $SUDO kill $openvpn_pids || true

        # Wait and check if processes have been terminated
        sleep 2
        openvpn_pids_remaining=$(pgrep openvpn)
        if [ -n "$openvpn_pids_remaining" ]; then
            echo "Forcing termination of remaining OpenVPN processes..."
            $SUDO kill -9 $openvpn_pids_remaining || true
        else
            echo "All OpenVPN processes terminated successfully."
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

    $SUDO apt-get update
    $SUDO apt-get -y install lsb-release ca-certificates curl
    $SUDO curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb
    $SUDO dpkg -i /tmp/debsuryorg-archive-keyring.deb
    $SUDO sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
    $SUDO apt-get update

    echo "Sury repositories installed successfully using the official method."
}

# Main script logic

# Check if sudo is available
if command -v sudo &>/dev/null; then
    SUDO="sudo"
else
    SUDO=""
fi

# Parse command-line arguments
custom_ovpn=""
disable_ovpn=false
add_sury_repos=false
delete_sury_repos=false
vpn_username=""
vpn_password=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
    -path=*) custom_ovpn="${1#*=}" ;;
    -disableovpn) disable_ovpn=true ;;
    -addsuryrepositories) add_sury_repos=true ;;
    -deletesuryrepositories) delete_sury_repos=true ;;
    -username=*) vpn_username="${1#*=}" ;;
    -password=*) vpn_password="${1#*=}" ;;
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

if $delete_sury_repos; then
    delete_sury_repositories "$os_family"
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

# Resolve the IPv4 address of the target site
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
    ovpn_files=("$script_dir"/*.ovpn)
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

# Handle VPN credentials if provided
if [[ -n "$vpn_username" && -n "$vpn_password" ]]; then
    echo "OpenVPN credentials provided."
    auth_file=$(mktemp)
    echo "$vpn_username" >"$auth_file"
    echo "$vpn_password" >>"$auth_file"
    chmod 600 "$auth_file"

    # Add auth-user-pass to OpenVPN config if not present
    if ! grep -q "auth-user-pass" "$ovpn_file"; then
        echo "auth-user-pass $auth_file" >>"$ovpn_file"
    else
        # Update existing auth-user-pass line
        sed -i "s|auth-user-pass.*|auth-user-pass $auth_file|" "$ovpn_file"
    fi
else
    echo "OpenVPN credentials not provided. If your VPN requires authentication, use -username and -password options."
fi

# Configure OpenVPN and start the daemon
configure_openvpn "$ovpn_file" "$target_ip"

# Clean up the temporary auth file if it was created
if [[ -n "$auth_file" ]]; then
    rm -f "$auth_file"
fi

echo "Script execution completed."
