#!/bin/bash

# Motorbike Sharing System Orchestrator
# Smart orchestration script for BE/FE repositories with comprehensive checks

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BE_REPO="https://github.com/FPTU-Capstone-Project/MotorbikeSharingSystem_BE.git"
FE_REPO="https://github.com/FPTU-Capstone-Project/MotorbikeSharingSystem_FE.git"
BE_DIR="backend"
FE_DIR="frontend"
BE_PORT=8080
FE_PORT=3000
LOG_DIR="logs"

# Create logs directory
mkdir -p $LOG_DIR

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_DIR/orchestrator.log"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_DIR/orchestrator.log"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    echo "[SUCCESS] $(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_DIR/orchestrator.log"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    echo "[WARNING] $(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_DIR/orchestrator.log"
}

# Check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        return 1
    fi
    return 0
}

# Auto-install missing dependencies
auto_install_deps() {
    if [ ! -f "scripts/install-deps.sh" ]; then
        warning "Dependency installer not found. Please install missing software manually."
        return 1
    fi
    
    log "Missing dependencies detected. Attempting auto-installation..."
    if ./scripts/install-deps.sh; then
        success "Dependencies installed successfully!"
        return 0
    else
        error "Auto-installation failed. Please install manually:"
        echo "  - Git: https://git-scm.com/"
        echo "  - Node.js: https://nodejs.org/"
        echo "  - Java 11+: https://adoptium.net/"
        echo "  - Maven: https://maven.apache.org/"
        echo "  - Docker: https://www.docker.com/products/docker-desktop/"
        return 1
    fi
}

# Check if port is available
check_port() {
    local port=$1
    local service=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        error "Port $port is already in use (needed for $service)"
        echo "Process using port $port:"
        lsof -Pi :$port -sTCP:LISTEN
        return 1
    fi
    success "Port $port is available for $service"
    return 0
}

# System requirements check
check_system_requirements() {
    log "Checking system requirements..."
    
    local requirements_met=true
    
    # Check required commands
    local required_commands=("git" "node" "npm")
    local missing_commands=()
    
    for cmd in "${required_commands[@]}"; do
        if ! check_command $cmd; then
            missing_commands+=("$cmd")
            requirements_met=false
        fi
    done
    
    # Try auto-installation if commands are missing
    if [ ${#missing_commands[@]} -gt 0 ]; then
        warning "Missing required commands: ${missing_commands[*]}"
        if auto_install_deps; then
            log "Re-checking requirements after installation..."
            # Re-check after installation
            for cmd in "${missing_commands[@]}"; do
                if ! check_command $cmd; then
                    requirements_met=false
                fi
            done
        else
            requirements_met=false
        fi
    fi
    
    # Check Java for backend (optional - try to install if missing)
    if ! command -v java &> /dev/null; then
        warning "Java is not installed. Backend requires Java 11 or higher."
        if auto_install_deps; then
            if ! command -v java &> /dev/null; then
                requirements_met=false
            fi
        else
            requirements_met=false
        fi
    else
        java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
        log "Java version: $java_version"
    fi
    
    # Check Maven (optional - try to install if missing)
    if ! command -v mvn &> /dev/null; then
        warning "Maven is not installed. Backend requires Maven."
        if auto_install_deps; then
            if ! command -v mvn &> /dev/null; then
                requirements_met=false
            fi
        else
            requirements_met=false
        fi
    else
        mvn_version=$(mvn -version | head -n 1)
        log "Maven version: $mvn_version"
    fi
    
    # Check Docker status (optional - can run without Docker)
    if ! docker info &> /dev/null; then
        warning "Docker is not running. Some features may be limited."
        warning "To use Docker mode, please start Docker Desktop."
    else
        success "Docker is running and available"
    fi
    
    # Check available ports
    if ! check_port $BE_PORT "Backend"; then
        requirements_met=false
    fi
    
    if ! check_port $FE_PORT "Frontend"; then
        requirements_met=false
    fi
    
    # Check disk space (minimum 2GB)
    available_space=$(df -h . | awk 'NR==2 {print $4}' | sed 's/G//')
    if (( $(echo "$available_space < 2" | bc -l) )); then
        error "Insufficient disk space. At least 2GB required."
        requirements_met=false
    else
        success "Sufficient disk space available: ${available_space}G"
    fi
    
    if [ "$requirements_met" = false ]; then
        error "System requirements not met. Please resolve the issues above."
        exit 1
    fi
    
    success "All system requirements met!"
}

# Clone or update repository
clone_or_update_repo() {
    local repo_url=$1
    local dir_name=$2
    
    if [ -d "$dir_name" ]; then
        log "Updating existing $dir_name repository..."
        cd $dir_name
        
        # Check if there are local changes
        if ! git diff-index --quiet HEAD --; then
            warning "Local changes detected in $dir_name. Stashing changes..."
            git stash push -m "Auto-stash before orchestrator update $(date)"
        fi
        
        git fetch origin
        local_commit=$(git rev-parse HEAD)
        remote_commit=$(git rev-parse origin/$(git rev-parse --abbrev-ref HEAD))
        
        if [ "$local_commit" != "$remote_commit" ]; then
            log "New changes available. Pulling latest updates..."
            git pull origin $(git rev-parse --abbrev-ref HEAD)
            success "Repository $dir_name updated successfully"
        else
            log "Repository $dir_name is already up to date"
        fi
        
        cd ..
    else
        log "Cloning $dir_name repository..."
        git clone $repo_url $dir_name
        success "Repository $dir_name cloned successfully"
    fi
}

# Install dependencies and build backend
setup_backend() {
    log "Setting up backend..."
    cd $BE_DIR
    
    # Use the existing dev.sh if available, otherwise use standard Maven commands
    if [ -f "dev.sh" ]; then
        log "Using existing dev.sh script for backend setup"
        chmod +x dev.sh
        ./dev.sh > "../$LOG_DIR/backend-build.log" 2>&1 &
    else
        log "Building backend with Maven..."
        mvn clean install -DskipTests > "../$LOG_DIR/backend-build.log" 2>&1
        success "Backend build completed"
        
        log "Starting backend server..."
        nohup mvn spring-boot:run > "../$LOG_DIR/backend-runtime.log" 2>&1 &
    fi
    
    cd ..
    success "Backend setup initiated"
}

# Install dependencies and start frontend
setup_frontend() {
    log "Setting up frontend..."
    cd $FE_DIR
    
    # Check if node_modules exists and package.json has changed
    if [ -f "package.json" ]; then
        if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules" ]; then
            log "Installing frontend dependencies..."
            npm install > "../$LOG_DIR/frontend-install.log" 2>&1
            success "Frontend dependencies installed"
        else
            log "Frontend dependencies already installed and up to date"
        fi
        
        log "Starting frontend development server..."
        nohup npm start > "../$LOG_DIR/frontend-runtime.log" 2>&1 &
        
    else
        error "package.json not found in frontend directory"
        exit 1
    fi
    
    cd ..
    success "Frontend setup completed"
}

# Wait for services to be ready
wait_for_services() {
    log "Waiting for services to start..."
    
    # Wait for backend
    log "Checking backend health..."
    for i in {1..30}; do
        if curl -s http://localhost:$BE_PORT/actuator/health &> /dev/null || \
           curl -s http://localhost:$BE_PORT/health &> /dev/null || \
           curl -s http://localhost:$BE_PORT &> /dev/null; then
            success "Backend is ready on port $BE_PORT"
            break
        fi
        
        if [ $i -eq 30 ]; then
            warning "Backend health check timeout. Check logs in $LOG_DIR/backend-runtime.log"
        else
            sleep 5
        fi
    done
    
    # Wait for frontend
    log "Checking frontend..."
    for i in {1..30}; do
        if curl -s http://localhost:$FE_PORT &> /dev/null; then
            success "Frontend is ready on port $FE_PORT"
            break
        fi
        
        if [ $i -eq 30 ]; then
            warning "Frontend startup timeout. Check logs in $LOG_DIR/frontend-runtime.log"
        else
            sleep 3
        fi
    done
}

# Display status and URLs
show_status() {
    echo ""
    echo "================================================"
    echo -e "${GREEN}🚀 Motorbike Sharing System is ready!${NC}"
    echo "================================================"
    echo ""
    echo -e "${BLUE}📱 Frontend:${NC} http://localhost:$FE_PORT"
    echo -e "${BLUE}⚙️  Backend:${NC}  http://localhost:$BE_PORT"
    echo ""
    echo -e "${YELLOW}📋 Logs:${NC}"
    echo "   Backend build: $LOG_DIR/backend-build.log"
    echo "   Backend runtime: $LOG_DIR/backend-runtime.log"
    echo "   Frontend install: $LOG_DIR/frontend-install.log"
    echo "   Frontend runtime: $LOG_DIR/frontend-runtime.log"
    echo "   Orchestrator: $LOG_DIR/orchestrator.log"
    echo ""
    echo -e "${YELLOW}🛑 To stop:${NC} ./orchestrator.sh stop"
    echo -e "${YELLOW}📊 Dashboard:${NC} ./orchestrator.sh dashboard"
    echo ""
}

# Stop all services
stop_services() {
    log "Stopping all services..."
    
    # Kill processes on specific ports
    if lsof -Pi :$BE_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        kill $(lsof -Pi :$BE_PORT -sTCP:LISTEN -t) 2>/dev/null || true
        success "Backend stopped"
    fi
    
    if lsof -Pi :$FE_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        kill $(lsof -Pi :$FE_PORT -sTCP:LISTEN -t) 2>/dev/null || true
        success "Frontend stopped"
    fi
    
    # Kill any remaining node/java processes from this orchestration
    pkill -f "mvn spring-boot:run" 2>/dev/null || true
    pkill -f "npm start" 2>/dev/null || true
    
    success "All services stopped"
}

# Status check
check_status() {
    echo "Service Status:"
    echo "==============="
    
    if lsof -Pi :$BE_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "Backend:  ${GREEN}✓ Running${NC} (port $BE_PORT)"
    else
        echo -e "Backend:  ${RED}✗ Not running${NC}"
    fi
    
    if lsof -Pi :$FE_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "Frontend: ${GREEN}✓ Running${NC} (port $FE_PORT)"
    else
        echo -e "Frontend: ${RED}✗ Not running${NC}"
    fi
    
    # Show latest logs
    echo ""
    echo "Recent logs:"
    echo "============"
    if [ -f "$LOG_DIR/orchestrator.log" ]; then
        tail -n 5 "$LOG_DIR/orchestrator.log"
    fi
}

# Main orchestration function
start_orchestration() {
    log "Starting Motorbike Sharing System orchestration..."
    
    check_system_requirements
    
    clone_or_update_repo $BE_REPO $BE_DIR
    clone_or_update_repo $FE_REPO $FE_DIR
    
    setup_backend
    setup_frontend
    
    wait_for_services
    show_status
}

# Main script logic
case "${1:-start}" in
    "start")
        start_orchestration
        ;;
    "stop")
        stop_services
        ;;
    "status")
        check_status
        ;;
    "restart")
        stop_services
        sleep 3
        start_orchestration
        ;;
    "dashboard")
        if command -v python3 &> /dev/null; then
            log "Starting dashboard..."
            python3 dashboard.py
        else
            error "Python3 not found. Dashboard requires Python3."
        fi
        ;;
    "logs")
        case "$2" in
            "backend")
                tail -f "$LOG_DIR/backend-runtime.log"
                ;;
            "frontend")
                tail -f "$LOG_DIR/frontend-runtime.log"
                ;;
            "all")
                tail -f "$LOG_DIR"/*.log
                ;;
            *)
                echo "Usage: $0 logs [backend|frontend|all]"
                ;;
        esac
        ;;
    "help")
        echo "Motorbike Sharing System Orchestrator"
        echo "====================================="
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  start     - Start all services (default)"
        echo "  stop      - Stop all services"
        echo "  restart   - Restart all services"
        echo "  status    - Check service status"
        echo "  dashboard - Open web dashboard"
        echo "  logs      - View logs [backend|frontend|all]"
        echo "  help      - Show this help message"
        ;;
    *)
        error "Unknown command: $1"
        echo "Use '$0 help' for available commands"
        exit 1
        ;;
esac