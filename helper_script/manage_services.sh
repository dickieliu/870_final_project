#!/bin/bash

# Services for Cowrie Project
SERVICES=("cowrie" "elasticsearch" "fail2ban" "filebeat" "kibana" "logstash" "nginx")

# Function to stop services
stop_services() {
    echo "Stopping services..."
    for service in "${SERVICES[@]}"; do
        sudo systemctl stop "$service"
        echo "$service stopped."
    done
}

# Function to start services
start_services() {
    echo "Starting services..."
    for service in "${SERVICES[@]}"; do
        sudo systemctl start "$service"
        echo "$service started."
    done
}

# Usage: script on|off
case "$1" in
    "on")
        start_services
        ;;
    "off")
        stop_services
        ;;
    *)
        echo "Usage: $0 {on|off}"
        exit 1
        ;;
esac

