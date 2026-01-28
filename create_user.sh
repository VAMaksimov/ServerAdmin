#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <username>" >&2
  exit 1
fi

USERNAME=$1
LOG_FILE="user_creation.log"

# Create user
if id "$USERNAME" &>/dev/null; then
  echo "User $USERNAME already exists."
else
  useradd -m -s /bin/bash "$USERNAME"
  echo "User $USERNAME created."
fi

# Add to docker group (so they can run docker without sudo)
usermod -aG docker "$USERNAME"

# Create Restricted Sudoers file
# This allows everything EXCEPT shells and switching users
cat <<EOF > "/etc/sudoers.d/$USERNAME"
$USERNAME ALL=(ALL) NOPASSWD: ALL, !/bin/bash, !/bin/sh, !/usr/bin/su, !/usr/bin/sudo -i, !/usr/bin/sudo -s, !/usr/bin/sudo su
EOF

chmod 0440 "/etc/sudoers.d/$USERNAME"

# Generate password
PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 12)
echo "$USERNAME:$PASSWORD" | chpasswd

echo "Username: $USERNAME, Password: $PASSWORD (Type: Standard User)" >> "$LOG_FILE"
echo "Setup complete. User cannot use 'sudo -i' or 'sudo su'."
