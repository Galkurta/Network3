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

    if ! command -v wget &> /dev/null; then
        log_message "INFO" "Installing wget..."
        sudo apt install -y wget || handle_error "Failed to install wget"
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
    fi
    
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

# Function to get API info with retry logic
get_api_info_retry() {
    if [ ! -d "${NODE_DIR}" ]; then
        return 1
    fi
    
    cd "${NODE_DIR}" 2>/dev/null || return 1
    
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
        return 0
    fi
    
    return 1
}

# Function to install prerequisites
install_prerequisites() {
    log_message "INFO" "Starting prerequisites installation..."
    
    # Update system
    log_message "INFO" "Updating system packages..."
    sudo apt update && sudo apt upgrade -y || handle_error "System update failed"
    
    # Check and install dependencies
    check_dependencies
    
    # Remove old screen sessions
    remove_network3_screens
    
    # Check if node directory exists and remove if it does
    if [ -d "${NODE_DIR}" ]; then
        log_message "INFO" "Removing existing node installation..."
        rm -rf "${NODE_DIR}"
    fi
    
    # Download and extract node
    log_message "INFO" "Downloading Network3 Node..."
    wget "$DOWNLOAD_URL" || handle_error "Download failed"
    
    log_message "INFO" "Extracting files..."
    tar -xvf "ubuntu-node-${NODE_VERSION}.tar" || handle_error "Extraction failed"
    rm -rf "ubuntu-node-${NODE_VERSION}.tar"
    
    log_message "INFO" "Prerequisites installation completed successfully"
    log_message "INFO" "You can now start the node using option 2 from the main menu"
}

# Function to start node first time
first_start_node() {
    if [ ! -d "${NODE_DIR}" ]; then
        handle_error "Prerequisites not installed. Please install prerequisites first (Option 1)"
    fi

    log_message "INFO" "Starting Network3 Node for the first time..."
    
    # Start node
    cd "${NODE_DIR}" || handle_error "Failed to change directory"
    
    # Check if node is already running
    if screen -list | grep -q "${SCREEN_NAME}"; then
        log_message "INFO" "Node is already running. Stopping it first..."
        stop_network3
        sleep 3
    fi

    # Run manager.sh up without screen first
    log_message "INFO" "Initializing node..."
    sudo bash manager.sh up
    
    # Check if initialization was successful
    if [ $? -eq 0 ]; then
        log_message "INFO" "Node initialization successful"
    else
        # If manager.sh up failed, try manager.sh down then up again
        log_message "WARN" "Initial start failed, trying recovery..."
        sudo bash manager.sh down
        sleep 2
        sudo bash manager.sh up || handle_error "Node initialization failed"
    fi
    
    # Wait for node to be ready
    sleep 5
    
    # Get server IP
    local server_ip
    server_ip=$(hostname -I | awk '{print $1}')
    
    # Display information
    log_message "INFO" "Node initialization completed."
    log_message "INFO" "You can access the dashboard at:"
    echo -e "${BLUE}https://account.network3.ai/main?o=${server_ip}:8080${NC}"
    
    # Start screen session
    log_message "INFO" "Starting screen session..."
    screen -S "${SCREEN_NAME}" -dm bash -c "sudo bash manager.sh up; exec bash"
    
    sleep 3
    
    # Try to get API info with retry
    local retry_count=0
    local max_retries=3
    
    while [ $retry_count -lt $max_retries ]; do
        if get_api_info_retry; then
            break
        fi
        ((retry_count++))
        log_message "WARN" "Retrying API info retrieval (Attempt $retry_count of $max_retries)..."
        sleep 3
    done
    
    log_message "INFO" "Node started successfully"
    log_message "WARN" "Please wait a few minutes for the node to fully initialize"
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
    first_start_node
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
    echo "2) First Start"
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
            1) install_prerequisites ;;
            2) first_start_node ;;
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