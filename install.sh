#!/bin/bash

# 🚀 Motorbike Sharing System - One-Click Installer
# This script sets up everything needed to run the complete application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Banner
echo -e "${MAGENTA}"
cat << 'EOF'
🏍️  MOTORBIKE SHARING SYSTEM
================================
   One-Click Installation
================================
EOF
echo -e "${NC}"

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "orchestrator.sh" ]; then
    error "This script must be run from the Repository-Orchestration directory"
    exit 1
fi

log "🔍 Checking system requirements..."

# Make scripts executable
chmod +x orchestrator.sh
chmod +x scripts/install-deps.sh
if [ -f "dashboard.py" ]; then
    chmod +x dashboard.py
fi

# Check and install dependencies
missing_deps=()

# Check essential tools
if ! command -v git &> /dev/null; then
    missing_deps+=("git")
fi

if ! command -v node &> /dev/null; then
    missing_deps+=("node")
fi

if ! command -v npm &> /dev/null; then
    missing_deps+=("npm")
fi

# Check backend tools
if ! command -v java &> /dev/null; then
    missing_deps+=("java")
fi

if ! command -v mvn &> /dev/null; then
    missing_deps+=("maven")
fi

# Install missing dependencies
if [ ${#missing_deps[@]} -gt 0 ]; then
    log "📦 Installing missing dependencies: ${missing_deps[*]}"
    
    # Try automatic installation
    if ./scripts/install-deps.sh; then
        success "✅ Dependencies installed successfully!"
    else
        warning "❌ Some dependencies couldn't be installed automatically."
        log "📝 Please install them manually:"
        for dep in "${missing_deps[@]}"; do
            case $dep in
                "git")
                    echo "   Git: https://git-scm.com/downloads"
                    ;;
                "node")
                    echo "   Node.js: https://nodejs.org/"
                    ;;
                "java")
                    echo "   Java 11+: https://adoptium.net/"
                    ;;
                "maven")
                    echo "   Maven: https://maven.apache.org/"
                    ;;
            esac
        done
        echo ""
        log "⚡ After installing, run this script again or use: ./orchestrator.sh"
        exit 1
    fi
else
    success "✅ All required dependencies are already installed!"
fi

# Check optional dependencies
log "🔍 Checking optional dependencies..."

optional_missing=()
if ! command -v docker &> /dev/null; then
    optional_missing+=("docker")
fi

if ! command -v python3 &> /dev/null; then
    optional_missing+=("python3")
fi

if [ ${#optional_missing[@]} -gt 0 ]; then
    warning "ℹ️  Optional dependencies missing: ${optional_missing[*]}"
    log "These are not required but provide additional features:"
    for dep in "${optional_missing[@]}"; do
        case $dep in
            "docker")
                echo "   Docker: Enables containerized deployment"
                ;;
            "python3")
                echo "   Python 3: Enables web dashboard"
                ;;
        esac
    done
    echo ""
fi

# Create necessary directories
log "📁 Setting up directories..."
mkdir -p logs
mkdir -p scripts

# Setup complete
success "🎉 Installation completed successfully!"
echo ""
echo -e "${GREEN}================================"
echo "🚀 READY TO START!"
echo "================================${NC}"
echo ""
echo -e "${BLUE}Quick Start:${NC}"
echo "1. Start all services: ${YELLOW}./orchestrator.sh${NC}"
echo "2. Open web dashboard: ${YELLOW}./orchestrator.sh dashboard${NC}"
echo "3. View logs: ${YELLOW}./orchestrator.sh logs all${NC}"
echo ""
echo -e "${BLUE}Access URLs:${NC}"
echo "• Frontend:  http://localhost:3000"
echo "• Backend:   http://localhost:8080"
echo "• Dashboard: http://localhost:5000"
echo ""
echo -e "${YELLOW}Starting the application now...${NC}"
echo ""

# Auto-start the application
./orchestrator.sh