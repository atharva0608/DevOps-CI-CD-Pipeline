#!/bin/bash

# Set the Instance ID and AWS region
INSTANCE_ID="i-069c3e20e17f4b9df"
AWS_REGION="us-west-2"

# Retrieve the public IP address of the specified EC2 instance
ipv4_address=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --region "$AWS_REGION" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

# Path to the .env file
file_to_find="../frontend/.env.docker"

# Exit if file doesn't exist
if [ ! -f "$file_to_find" ]; then
  echo "ERROR: .env file not found at $file_to_find"
  exit 1
fi

# Read the current line containing VITE_API_PATH
current_line=$(grep ^VITE_API_PATH "$file_to_find")

# Desired line with updated IP
new_line="VITE_API_PATH=\"http://${ipv4_address}:31100\""

# Update if different
if [[ "$current_line" != "$new_line" ]]; then
  sed -i -e "s|^VITE_API_PATH.*|$new_line|g" "$file_to_find"
  echo "Updated VITE_API_PATH to $new_line"
else
  echo "VITE_API_PATH is already up to date."
fi
