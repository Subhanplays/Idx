#!/bin/bash
set -euo pipefail

# -------------------------
# Color Definitions
# -------------------------
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
RESET='\e[0m'

# -------------------------
# KVM Check Function
# -------------------------
check_kvm_support() {
    echo -e "${YELLOW}Checking KVM support...${RESET}"
    
    # Check CPU virtualization support
    if ! egrep -c '(vmx|svm)' /proc/cpuinfo > /dev/null 2>&1; then
        echo -e "${RED}❌ CPU virtualization not supported or disabled in BIOS${RESET}"
        return 1
    fi
    
    # Check KVM module
    if ! lsmod | grep kvm > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  KVM module not loaded. Trying to load...${RESET}"
        sudo modprobe kvm 2>/dev/null || true
        sudo modprobe kvm_intel 2>/dev/null || sudo modprobe kvm_amd 2>/dev/null || true
    fi
    
    # Check /dev/kvm
    if [ ! -e /dev/kvm ]; then
        echo -e "${RED}❌ /dev/kvm not found${RESET}"
        return 1
    fi
    
    echo -e "${GREEN}✅ KVM support available${RESET}"
    return 0
}

# -------------------------
# Animate Logo - SUBHANPLAYS
# -------------------------
animate_logo() {
  clear
  local logo=(
    "  ____           _                      _                 "
    " / ___| _   _ ___| |__   __ _ _ __   __| | __ _ _ __ ___  "
    " \___ \| | | / __| '_ \ / _\` | '_ \ / _\` |/ _\` | '_ \` _ \ "
    "  ___) | |_| \__ \ | | | (_| | | | | (_| | (_| | | | | | |"
    " |____/ \__,_|___/_| |_|\__,_|_| |_|\__,_|\__,_|_| |_| |_|"
    "                                                          "
  )
  
  for line in "${logo[@]}"; do
    echo -e "${CYAN}${line}${RESET}"
    sleep 0.2
  done
  echo ""
  sleep 0.5
}

# -------------------------
# Show Animated Logo
# -------------------------
animate_logo

echo -e "${YELLOW}Subhanplays VM Setup${RESET}"
echo ""

# -------------------------
# System diagnostics
# -------------------------
echo -e "${YELLOW}Performing system diagnostics...${RESET}"

# Check system resources
if ! check_kvm_support; then
    echo -e "${RED}KVM not available. VM will run in emulation mode (slower)${RESET}"
    echo -e "${YELLOW}To enable KVM:${RESET}"
    echo -e "${CYAN}1. Enable virtualization in BIOS/UEFI settings${RESET}"
    echo -e "${CYAN}2. Run: sudo modprobe kvm kvm_intel (Intel) or kvm_amd (AMD)${RESET}"
fi

# -------------------------
# Create .idx directory and dev.nix file
# -------------------------
echo -e "${YELLOW}Setting up development environment...${RESET}"
cd
rm -rf myapp
rm -rf flutter

# Create vps123 directory if it doesn't exist
mkdir -p vps123
cd vps123

if [ ! -d ".idx" ]; then
  mkdir .idx
  cd .idx
  cat <<EOF > dev.nix
{ pkgs, ... }: {
  # Which nixpkgs channel to use
  channel = "stable-24.05"; # or "unstable"

  # Packages to be installed in the development environment
  packages = with pkgs; [
    unzip
    openssh
    git
    qemu_kvm
    sudo
    cdrkit
    cloud-utils
    qemu
  ];

  # Environment variables for the workspace
  env = {
    # Example: set default editor
    EDITOR = "nano";
  };

  idx = {
    # Extensions from https://open-vsx.org (use "publisher.id")
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];

    workspace = {
      # Runs when a workspace is first created
      onCreate = { };

      # Runs each time the workspace is (re)started
      onStart = { };
    };

    # Disable previews completely
    previews = {
      enable = false;
    };
  };
}
EOF
  cd ..
  echo -e "${GREEN}✓ dev.nix file created successfully in .idx directory${RESET}"
else
  echo -e "${GREEN}✓ .idx directory already exists${RESET}"
fi

# -------------------------
# Ask for confirmation before starting VM
# -------------------------
echo ""
echo -e "${YELLOW}Development environment setup completed!${RESET}"
echo -ne "${CYAN}Do you want to start the VM? (y/n): ${RESET}"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${GREEN}Starting VM setup...${RESET}"
    
    # URL for VM script
    google_url="https://raw.githubusercontent.com/hopingboyz/vms/main/vm.sh"
    
    # Run the VM script
    bash <(curl -fsSL "$google_url")
else
    echo -e "${RED}VM setup cancelled.${RESET}"
    echo -e "${YELLOW}You can run it later with:${RESET}"
    echo -e "${CYAN}bash <(curl -fsSL https://raw.githubusercontent.com/hopingboyz/vms/main/vm.sh)${RESET}"
fi

# -------------------------
# Made by Subhanplays done!
# -------------------------
echo -e "${CYAN}Made by Subhanplays done!${RESET}"
