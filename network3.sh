#!/bin/bash

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Banner function
show_banner() {
    clear
    echo -e "${BLUE}
███╗   ██╗███████╗████████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗██████╗ 
████╗  ██║██╔════╝╚══██╔══╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝╚════██╗
██╔██╗ ██║█████╗     ██║   ██║ █╗ ██║██║   ██║██████╔╝█████╔╝  █████╔╝
██║╚██╗██║██╔══╝     ██║   ██║███╗██║██║   ██║██╔══██╗██╔═██╗  ╚═══██╗
██║ ╚████║███████╗   ██║   ╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗██████╔╝
╚═╝  ╚═══╝╚══════╝   ╚═╝    ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ 
=======================================================
Author  : Galkurta
GitHub  : https://github.com/Galkurta
=======================================================
${NC}"
}

# Configuration
NODE_VERSION="v2.1.0"
DOWNLOAD_URL="https://network3.io/ubuntu-node-${NODE_VERSION}.tar"
SCREEN_NAME="network3"
NODE_DIR="ubuntu-node"

# Error handling function
handle_error() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

# Logging function
log_message() {
    local level=$1
    local message=$2
    case $level in
        "INFO")
            echo -e "${GREEN}[INFO] $message${NC}"
            ;;
        "WARN")
            echo -e "${YELLOW}[WARN] $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR] $message${NC}"
            ;;
    esac
}

# Function to check if screen is installed
check_dependencies() {
    if ! command -v screen &> /dev/null; then
        log_message "INFO" "Installing screen..."
        sudo apt install -y screen || handle_error "Failed to install screen"
    fi
    
    if ! command -v net-tools &> /dev/null; then
        log_message "INFO" "Installing net-tools..."
        sudo apt install -y net-tools || handle_error "Failed to install net-tools"
    fi
}

# Function to remove all network3 screen sessions
remove_network3_screens() {
    log_message "INFO" "Removing all screen sessions with '${SCREEN_NAME}'..."
    screen -list | grep "${SCREEN_NAME}" | cut -d. -f1 | xargs -I {} screen -S {} -X quit 2>/dev/null
}

# Function to get API key information
get_api_info() {
    if [ ! -d "${NODE_DIR}" ]; then
        handle_error "Node not installed. Please install prerequisites first."
    }
    
    cd "${NODE_DIR}" 2>/dev/null || handle_error "Failed to change directory"
    
    local api_output
    api_output=$(sudo bash manager.sh key)
    local api_key
    api_key=$(echo "$api_output" | awk '/System architecture is x86_64 \(64-bit\)/ {found=1; next} found')
    
    if [ -n "$api_key" ]; then
        echo -e "${GREEN}API KEY INFO:${NC}"
        echo -e "${BLUE}$api_key${NC}"
        
        # Display sync link
        local server_ip
        server_ip=$(hostname -I | awk '{print $1}')
        local sync_link="https://account.network3.ai/main?o=${server_ip}:8080"
        
        echo -e "\n${GREEN}Sync Link:${NC}"
        echo -e "${BLUE}${sync_link}${NC}"
    else
        log_message "ERROR" "Failed to retrieve API key information."
    fi
}

# Function for first start
first_start_network3() {
    log_message "INFO" "Starting initial setup for Network3 Node..."
    
    # Update system
    log_message "INFO" "Updating system packages..."
    sudo apt update && sudo apt upgrade -y || handle_error "System update failed"
    
    # Check dependencies
    check_dependencies
    
    # Remove old screen sessions
    remove_network3_screens
    
    # Download and extract node
    log_message "INFO" "Downloading Network3 Node..."
    wget "$DOWNLOAD_URL" || handle_error "Download failed"
    
    log_message "INFO" "Extracting files..."
    tar -xvf "ubuntu-node-${NODE_VERSION}.tar" || handle_error "Extraction failed"
    rm -rf "ubuntu-node-${NODE_VERSION}.tar"
    
    # Start node
    cd "${NODE_DIR}" || handle_error "Failed to change directory"
    screen -S "${SCREEN_NAME}" -dm bash -c "sudo bash manager.sh up; exec bash"
    
    sleep 5
    get_api_info
    
    # Display sync link
    local server_ip
    server_ip=$(hostname -I | awk '{print $1}')
    local sync_link="https://account.network3.ai/main?o=${server_ip}:8080"
    
    echo -e "\nSync Link:"
    echo -e "\033]8;;${sync_link}\033\\${sync_link}\033]8;;\033\\"
}

# Function to start node
start_network3() {
    log_message "INFO" "Starting Network3 Node..."
    
    if [ ! -d "${NODE_DIR}" ]; then
        handle_error "Directory '${NODE_DIR}' does not exist"
    }
    
    cd "${NODE_DIR}" || handle_error "Failed to change directory"
    
    if screen -list | grep -q "${SCREEN_NAME}"; then
        log_message "WARN" "Screen session '${SCREEN_NAME}' already exists"
        screen -r "${SCREEN_NAME}"
    else
        screen -S "${SCREEN_NAME}" -dm bash -c "sudo bash manager.sh up; exec bash"
        log_message "INFO" "Node started successfully"
    fi
}

# Function to stop node
stop_network3() {
    log_message "INFO" "Stopping Network3 Node..."
    
    cd "${NODE_DIR}" 2>/dev/null || handle_error "Failed to change directory"
    
    if screen -list | grep -q "${SCREEN_NAME}"; then
        sudo bash manager.sh down
        screen -S "${SCREEN_NAME}" -X quit
        log_message "INFO" "Node stopped successfully"
    else
        log_message "WARN" "No active screen session found"
    fi
    
    remove_network3_screens
}

# Function to restart node
restart_network3() {
    log_message "INFO" "Restarting Network3 Node..."
    stop_network3
    sleep 2
    start_network3
    log_message "INFO" "Node restarted successfully"
}

# Function to view logs
view_logs_network3() {
    if screen -list | grep -q "${SCREEN_NAME}"; then
        screen -r "${SCREEN_NAME}"
    else
        log_message "ERROR" "No active screen session found"
    fi
}

# Main menu function
show_menu() {
    echo -e "\nSelect an action:"
    echo "1) Install Prerequisites"
    echo "2) Start"
    echo "3) Stop"
    echo "4) Restart"
    echo "5) View logs"
    echo "6) Show API Info"
    echo "0) Exit"
    echo
    read -rp "Enter your choice: " choice
    echo
}

# Main loop
main() {
    while true; do
        show_banner
        show_menu
        
        case $choice in
            1) first_start_network3 ;;
            2) start_network3 ;;
            3) stop_network3 ;;
            4) restart_network3 ;;
            5) view_logs_network3 ;;
            6) get_api_info ;;
            0)
                log_message "INFO" "Exiting..."
                exit 0
                ;;
            *)
                log_message "ERROR" "Invalid choice"
                ;;
        esac
        
        echo -e "\nPress Enter to continue..."
        read -r
    done
}

# Start script
main