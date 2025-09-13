#!/bin/bash

# Python Virtual Environment Setup Script
# Similar to node_modules concept for Python dependencies

set -e

VENV_DIR="venv"
REQUIREMENTS_FILE="requirements.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
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

# Check if Python3 is available
if ! command -v python3 &> /dev/null; then
    error "Python3 not found. Please install Python3 first."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    log "Creating Python virtual environment..."
    python3 -m venv $VENV_DIR
    success "Virtual environment created in $VENV_DIR/"
else
    log "Virtual environment already exists"
fi

# Activate virtual environment and install dependencies
log "Installing Python dependencies..."

# Different activation methods for different OS
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows
    source $VENV_DIR/Scripts/activate
else
    # macOS/Linux
    source $VENV_DIR/bin/activate
fi

# Upgrade pip first
pip install --upgrade pip

# Install requirements
if [ -f "$REQUIREMENTS_FILE" ]; then
    pip install -r $REQUIREMENTS_FILE
    success "All Python dependencies installed successfully!"
else
    error "requirements.txt not found!"
    exit 1
fi

# Create activation helper script
cat > activate-env.sh << 'EOF'
#!/bin/bash
# Quick activation script for Python virtual environment

if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi

echo "🐍 Python virtual environment activated!"
echo "💡 To deactivate, run: deactivate"
EOF

chmod +x activate-env.sh

echo ""
echo "================================================"
echo -e "${GREEN}🐍 Python Environment Setup Complete!${NC}"
echo "================================================"
echo ""
echo -e "${BLUE}📦 Virtual Environment:${NC} $VENV_DIR/"
echo -e "${BLUE}📋 Installed packages:${NC}"
pip list --format=table
echo ""
echo -e "${YELLOW}💡 Usage:${NC}"
echo "  • Activate: source activate-env.sh"
echo "  • Deactivate: deactivate"
echo "  • Run dashboard: python dashboard.py (after activation)"
echo ""