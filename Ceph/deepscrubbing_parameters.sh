#!/bin/bash

# Function to install bc based on the Linux distribution
install_bc() {
    local os_distro=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
    if [[ "$os_distro" == *"Ubuntu"* || "$os_distro" == *"Debian"* ]]; then
        sudo apt-get update
        sudo apt-get install -y bc
    elif [[ "$os_distro" == *"CentOS"* || "$os_distro" == *"Red Hat"* || "$os_distro" == *"Fedora"* ]]; then
        sudo yum install -y bc
    else
        echo "Error: Unsupported Linux distribution. Please install bc manually."
        exit 1
    fi
}

# Check if bc is installed
if ! command -v bc &> /dev/null; then
    echo "bc is not installed. Attempting to install..."
    install_bc
    if ! command -v bc &> /dev/null; then
        echo "Error: bc installation failed. Please install bc manually."
        exit 1
    fi
fi

# Define an associative array to store parameter values
declare -A param_values

# Define an array of scrubbing parameters
scrub_params=(
    "osd_scrub_during_recovery"
    "osd_scrub_auto_repair"
    "osd_scrub_begin_hour"
    "osd_scrub_end_hour"
    "osd_scrub_begin_week_day"
    "osd_scrub_end_week_day"
    "osd_scrub_min_interval"
    "osd_scrub_max_interval"
    "osd_deep_scrub_interval"
    "osd_scrub_priority"
    "osd_scrub_sleep"
    "osd_max_scrubs"
)

# Function to convert seconds to hours
seconds_to_hours() {
    local seconds=$1
    local hours=$(echo "scale=0; $seconds / 3600" | bc)
    echo "$hours hour(s)"
}

# Function to convert seconds to days and hours
seconds_to_days_hours() {
    local seconds=$1
    local days=$(echo "scale=0; $seconds / 86400" | bc)
    local remaining_seconds=$(echo "$seconds % 86400" | bc)
    local hours=$(echo "scale=0; $remaining_seconds / 3600" | bc)
    echo "$days day(s) $hours hour(s)"
}

# Loop through the array and retrieve the values of each parameter
for param in "${scrub_params[@]}"; do
    ceph_output=$(ceph config get osd "$param")
    # Convert osd_scrub_min_interval, osd_scrub_max_interval, and osd_deep_scrub_interval values
    # to hours and days respectively
    if [[ "$param" == "osd_scrub_min_interval" || "$param" == "osd_scrub_max_interval" ]]; then
        ceph_output=$(seconds_to_hours "$ceph_output")
    elif [[ "$param" == "osd_deep_scrub_interval" ]]; then
        ceph_output=$(seconds_to_days_hours "$ceph_output")
    fi
    param_values["$param"]=$ceph_output
done

# Print the table
echo "Parameter                 | Value"
echo "-------------------------------------"
for param in "${scrub_params[@]}"; do
    printf "%-25s | %s\n" "$param" "${param_values[$param]}"
done