#!/bin/bash

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

# Add to sudo and docker
usermod -aG sudo "$USERNAME"
usermod -aG docker "$USERNAME"

# Full Sudoers access
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME"
chmod 0440 "/etc/sudoers.d/$USERNAME"

# Generate password
PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 12)
echo "$USERNAME:$PASSWORD" | chpasswd

echo "Username: $USERNAME, Password: $PASSWORD (Type: Full Admin)" >> "$LOG_FILE"
echo "Setup complete. Admin has full root access."
