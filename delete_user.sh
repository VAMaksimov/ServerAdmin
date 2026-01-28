#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Check if a username is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <username>" >&2
  exit 1
fi

USERNAME=$1
LOG_FILE="user_creation.log"

# Check if user exists
if ! id "$USERNAME" &>/dev/null; then
  echo "Error: User $USERNAME does not exist."
  exit 1
fi

# 1. Remove the user and their home directory (-r)
userdel -r "$USERNAME"
echo "User $USERNAME and their home directory have been removed."

# 2. Remove the specific sudoers file
if [ -f "/etc/sudoers.d/$USERNAME" ]; then
  rm "/etc/sudoers.d/$USERNAME"
  echo "Sudo permissions for $USERNAME removed."
fi

# 3. Remove the user entry from the log file
if [ -f "$LOG_FILE" ]; then
  # Create a temporary file excluding the deleted user
  grep -v "^Username: $USERNAME," "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
  echo "User entry removed from $LOG_FILE."
fi

echo "Deletion of $USERNAME complete."
