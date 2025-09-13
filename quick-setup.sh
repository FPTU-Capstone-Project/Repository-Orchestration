#!/bin/bash
# 🚀 ONE-COMMAND SETUP for Motorbike Sharing System
# For completely fresh machines with just the OS

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${MAGENTA}"
cat << 'EOF'
🏍️  MOTORBIKE SHARING SYSTEM
================================
   ONE-COMMAND SETUP
   From Zero to Running Project
================================
EOF
echo -e "${NC}"

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check OS
OS=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS="windows"
else
    error "Unsupported OS: $OSTYPE"
    exit 1
fi

log "Detected OS: $OS"

# Install Git if not present
if ! command -v git &> /dev/null; then
    log "Installing Git..."
    case $OS in
        "mac")
            if command -v brew &> /dev/null; then
                brew install git
            else
                log "Installing Homebrew first..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                brew install git
            fi
            ;;
        "linux")
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y git
            elif command -v yum &> /dev/null; then
                sudo yum install -y git
            else
                error "Cannot auto-install Git on this Linux distribution"
                exit 1
            fi
            ;;
        "windows")
            error "Please install Git manually from: https://git-scm.com/download/win"
            error "Then run this script in Git Bash"
            exit 1
            ;;
    esac
    success "Git installed successfully"
else
    success "Git already installed"
fi

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    warning "Docker not found - this is REQUIRED!"
    echo ""
    echo -e "${YELLOW}Please install Docker Desktop:${NC}"
    case $OS in
        "mac")
            echo "Download: https://desktop.docker.com/mac/main/amd64/Docker.dmg"
            ;;
        "linux")
            echo "Follow: https://docs.docker.com/engine/install/"
            ;;
        "windows")
            echo "Download: https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
            ;;
    esac
    echo ""
    echo "After installing Docker Desktop:"
    echo "1. Open Docker Desktop and wait for it to start"
    echo "2. Run this script again"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    error "Docker Desktop is installed but not running!"
    echo ""
    echo "Please start Docker Desktop and wait for it to be ready, then run this script again."
    exit 1
fi

success "Docker is running"

# Install Node.js if not present
if ! command -v node &> /dev/null; then
    log "Installing Node.js..."
    case $OS in
        "mac")
            if ! command -v brew &> /dev/null; then
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install node
            ;;
        "linux")
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        "windows")
            warning "Please install Node.js manually from: https://nodejs.org/"
            exit 1
            ;;
    esac
    success "Node.js installed"
else
    success "Node.js already installed"
fi

# Install Java if not present
if ! command -v java &> /dev/null; then
    log "Installing Java..."
    case $OS in
        "mac")
            brew install --cask temurin
            ;;
        "linux")
            sudo apt update && sudo apt install -y openjdk-17-jdk
            ;;
        "windows")
            warning "Please install Java 17+ manually from: https://adoptium.net/"
            exit 1
            ;;
    esac
    success "Java installed"
else
    success "Java already installed"
fi

# Install Maven if not present
if ! command -v mvn &> /dev/null; then
    log "Installing Maven..."
    case $OS in
        "mac")
            brew install maven
            ;;
        "linux")
            sudo apt update && sudo apt install -y maven
            ;;
        "windows")
            warning "Please install Maven manually from: https://maven.apache.org/"
            exit 1
            ;;
    esac
    success "Maven installed"
else
    success "Maven already installed"
fi

# Install Python if not present
if ! command -v python3 &> /dev/null; then
    log "Installing Python..."
    case $OS in
        "mac")
            brew install python
            ;;
        "linux")
            sudo apt update && sudo apt install -y python3 python3-pip
            ;;
        "windows")
            warning "Please install Python manually from: https://python.org/"
            exit 1
            ;;
    esac
    success "Python installed"
else
    success "Python already installed"
fi

# Clone repository if not exists
if [ ! -d "Repository-Orchestration" ]; then
    log "Cloning project repository..."
    git clone https://github.com/FPTU-Capstone-Project/Repository-Orchestration.git
    success "Repository cloned"
else
    success "Repository already exists"
fi

cd Repository-Orchestration

# Make scripts executable
chmod +x *.sh

# Start the system
log "Starting Motorbike Sharing System..."
./orchestrator.sh

success "🎉 Setup completed! Your Motorbike Sharing System is now running!"
echo ""
echo -e "${GREEN}================================"
echo "🌐 ACCESS YOUR APPLICATION:"
echo "================================${NC}"
echo "Frontend:  http://localhost:3000"
echo "Backend:   http://localhost:8081"  
echo "Dashboard: http://localhost:5001"
echo ""
echo -e "${BLUE}To stop everything: ./orchestrator.sh stop${NC}"