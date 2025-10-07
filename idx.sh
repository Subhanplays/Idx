#!/bin/bash

# Display Subhanplays logo with colors
echo -e "\033[1;36m"
echo "  ____           _                      _                 "
echo " / ___| _   _ ___| |__   __ _ _ __   __| | __ _ _ __ ___  "
echo " \___ \| | | / __| '_ \ / _\` | '_ \ / _\` |/ _\` | '_ \` _ \ "
echo "  ___) | |_| \__ \ | | | (_| | | | | (_| | (_| | | | | | |"
echo " |____/ \__,_|___/_| |_|\__,_|_| |_|\__,_|\__,_|_| |_| |_|"
echo -e "\033[0m"
echo -e "\033[1;33mSubhanplays Development Environment Setup\033[0m"
echo ""

# Create .idx directory and dev.nix file
echo -e "\033[1;32mSetting up development environment...\033[0m"
mkdir -p .idx
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

echo -e "\033[1;32m✓ dev.nix file created successfully in .idx directory\033[0m"

# Return to original directory
cd ..

# Run the vm.sh script
echo -e "\033[1;35mStarting VM setup...\033[0m"
bash <(curl -fsSL https://raw.githubusercontent.com/hopingboyz/vms/main/vm.sh)
