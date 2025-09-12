#!/bin/bash

# Dependency Installation Script for Motorbike Sharing System Orchestration
# Automatically installs missing dependencies based on the operating system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[INSTALL]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            echo "debian"
        elif [ -f /etc/redhat-release ]; then
            echo "redhat"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Check if command exists
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# Install Git
install_git() {
    local os=$1
    log "Installing Git..."
    
    case $os in
        "macos")
            if check_command brew; then
                brew install git
            else
                error "Homebrew not found. Please install Homebrew first or install Git manually."
                return 1
            fi
            ;;
        "debian")
            sudo apt update
            sudo apt install -y git
            ;;
        "redhat")
            sudo yum install -y git || sudo dnf install -y git
            ;;
        "windows")
            warning "Please install Git from https://git-scm.com/downloads"
            return 1
            ;;
        *)
            error "Unsupported operating system for automatic Git installation"
            return 1
            ;;
    esac
    
    success "Git installed successfully"
}

# Install Node.js and npm
install_nodejs() {
    local os=$1
    log "Installing Node.js and npm..."
    
    case $os in
        "macos")
            if check_command brew; then
                brew install node
            else
                error "Homebrew not found. Please install Homebrew first or install Node.js manually."
                return 1
            fi
            ;;
        "debian")
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        "redhat")
            curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
            sudo yum install -y nodejs || sudo dnf install -y nodejs
            ;;
        "windows")
            warning "Please install Node.js from https://nodejs.org/"
            return 1
            ;;
        *)
            error "Unsupported operating system for automatic Node.js installation"
            return 1
            ;;
    esac
    
    success "Node.js and npm installed successfully"
}

# Install Java
install_java() {
    local os=$1
    log "Installing Java..."
    
    case $os in
        "macos")
            if check_command brew; then
                brew install openjdk@11
                echo 'export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"' >> ~/.zshrc
                source ~/.zshrc
            else
                error "Homebrew not found. Please install Homebrew first or install Java manually."
                return 1
            fi
            ;;
        "debian")
            sudo apt update
            sudo apt install -y openjdk-11-jdk
            ;;
        "redhat")
            sudo yum install -y java-11-openjdk-devel || sudo dnf install -y java-11-openjdk-devel
            ;;
        "windows")
            warning "Please install Java 11 from https://adoptium.net/"
            return 1
            ;;
        *)
            error "Unsupported operating system for automatic Java installation"
            return 1
            ;;
    esac
    
    success "Java installed successfully"
}

# Install Maven
install_maven() {
    local os=$1
    log "Installing Maven..."
    
    case $os in
        "macos")
            if check_command brew; then
                brew install maven
            else
                error "Homebrew not found. Please install Homebrew first or install Maven manually."
                return 1
            fi
            ;;
        "debian")
            sudo apt update
            sudo apt install -y maven
            ;;
        "redhat")
            sudo yum install -y maven || sudo dnf install -y maven
            ;;
        "windows")
            warning "Please install Maven from https://maven.apache.org/install.html"
            return 1
            ;;
        *)
            error "Unsupported operating system for automatic Maven installation"
            return 1
            ;;
    esac
    
    success "Maven installed successfully"
}

# Install Docker
install_docker() {
    local os=$1
    log "Installing Docker..."
    
    case $os in
        "macos")
            warning "Please install Docker Desktop from https://www.docker.com/products/docker-desktop/"
            warning "Docker installation requires manual setup on macOS"
            return 1
            ;;
        "debian")
            sudo apt update
            sudo apt install -y ca-certificates curl gnupg lsb-release
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt update
            sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            sudo usermod -aG docker $USER
            warning "Please log out and log back in to use Docker without sudo"
            ;;
        "redhat")
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
            warning "Please log out and log back in to use Docker without sudo"
            ;;
        "windows")
            warning "Please install Docker Desktop from https://www.docker.com/products/docker-desktop/"
            return 1
            ;;
        *)
            error "Unsupported operating system for automatic Docker installation"
            return 1
            ;;
    esac
    
    success "Docker installed successfully"
}

# Install Python 3
install_python() {
    local os=$1
    log "Installing Python 3..."
    
    case $os in
        "macos")
            if check_command brew; then
                brew install python@3.9
            else
                error "Homebrew not found. Please install Homebrew first or install Python manually."
                return 1
            fi
            ;;
        "debian")
            sudo apt update
            sudo apt install -y python3 python3-pip python3-venv
            ;;
        "redhat")
            sudo yum install -y python3 python3-pip || sudo dnf install -y python3 python3-pip
            ;;
        "windows")
            warning "Please install Python 3 from https://www.python.org/downloads/"
            return 1
            ;;
        *)
            error "Unsupported operating system for automatic Python installation"
            return 1
            ;;
    esac
    
    success "Python 3 installed successfully"
}

# Main installation function
main() {
    log "Starting dependency installation for Motorbike Sharing System..."
    
    local os=$(detect_os)
    log "Detected operating system: $os"
    
    local missing_deps=()
    
    # Check each dependency
    if ! check_command git; then
        missing_deps+=("git")
    fi
    
    if ! check_command node; then
        missing_deps+=("nodejs")
    fi
    
    if ! check_command java; then
        missing_deps+=("java")
    fi
    
    if ! check_command mvn; then
        missing_deps+=("maven")
    fi
    
    if ! check_command docker; then
        missing_deps+=("docker")
    fi
    
    if ! check_command python3; then
        missing_deps+=("python")
    fi
    
    if [ ${#missing_deps[@]} -eq 0 ]; then
        success "All dependencies are already installed!"
        exit 0
    fi
    
    log "Missing dependencies: ${missing_deps[*]}"
    
    # Install missing dependencies
    for dep in "${missing_deps[@]}"; do
        case $dep in
            "git")
                install_git "$os" || warning "Failed to install Git automatically"
                ;;
            "nodejs")
                install_nodejs "$os" || warning "Failed to install Node.js automatically"
                ;;
            "java")
                install_java "$os" || warning "Failed to install Java automatically"
                ;;
            "maven")
                install_maven "$os" || warning "Failed to install Maven automatically"
                ;;
            "docker")
                install_docker "$os" || warning "Failed to install Docker automatically"
                ;;
            "python")
                install_python "$os" || warning "Failed to install Python automatically"
                ;;
        esac
    done
    
    log "Dependency installation completed!"
    log "Please run './orchestrator.sh' to start the application"
}

# Run main function
main "$@"