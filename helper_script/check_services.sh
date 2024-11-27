#!/bin/bash

# Services for Cowrie Project
SERVICES=("cowrie" "elasticsearch" "fail2ban" "filebeat" "kibana" "logstash" "nginx")

# Function to check the status of each service
check_status() {
    echo "Checking service statuses..."
    for service in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$service"; then
            echo "$service is running."
        else
            echo "$service is not running."
        fi
    done
}

# Call the function to check statuses
check_status

