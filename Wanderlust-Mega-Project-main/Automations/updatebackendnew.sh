#!/bin/bash

# Set the Instance ID and AWS region
INSTANCE_ID="i-08a9e983c77f640fd"
AWS_REGION="us-east-2" 

# Path to the .env file
file_to_find="../backend/.env.docker"

# Retrieve the public IP address of the specified EC2 instance in the specified region
ipv4_address=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --region "$AWS_REGION" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

# Check if retrieval was successful
if [[ "$ipv4_address" == "None" || -z "$ipv4_address" ]]; then
  echo "ERROR: Unable to retrieve public IP for instance $INSTANCE_ID in region $AWS_REGION"
  exit 1
fi

# Get current FRONTEND_URL from the .env file
if [ -f "$file_to_find" ]; then
  current_url=$(sed -n "4p" "$file_to_find")

  # Update .env file only if IP has changed
  new_url="FRONTEND_URL=\"http://${ipv4_address}:5173\""
  if [[ "$current_url" != "$new_url" ]]; then
    sed -i -e "s|FRONTEND_URL.*|$new_url|g" "$file_to_find"
    echo "Updated FRONTEND_URL to $new_url"
  else
    echo "FRONTEND_URL is already up to date."
  fi
else
  echo "ERROR: File $file_to_find not found."
  exit 1
fi
