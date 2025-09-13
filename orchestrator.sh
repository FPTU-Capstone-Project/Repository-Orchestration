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
BE_PORT=8081
FE_PORT=3000
LOG_DIR="logs"

# Create logs directory
mkdir -p $LOG_DIR

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
    mkdir -p "$LOG_DIR"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_DIR/orchestrator.log"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    mkdir -p "$LOG_DIR"
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_DIR/orchestrator.log"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    mkdir -p "$LOG_DIR"
    echo "[SUCCESS] $(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_DIR/orchestrator.log"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    mkdir -p "$LOG_DIR"
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

# Force kill processes on specific port
force_kill_port() {
    local port=$1
    local service=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        warning "Port $port is in use, stopping conflicting process for $service..."
        local pids=$(lsof -Pi :$port -sTCP:LISTEN -t)
        for pid in $pids; do
            log "Killing process $pid on port $port"
            kill -9 $pid 2>/dev/null || true
        done
        sleep 2
        
        # Double-check if port is now free
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            error "Failed to free port $port completely"
            return 1
        else
            success "Port $port is now available for $service"
        fi
    else
        success "Port $port is available for $service"
    fi
    return 0
}

# Check if port is available (legacy function for compatibility)
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
    
    # Check available ports (with auto-cleanup option)
    if ! check_port $BE_PORT "Backend"; then
        if [ "${AUTO_KILL_PORTS:-true}" = "true" ]; then
            log "Auto-cleanup enabled. Attempting to free port $BE_PORT..."
            force_kill_port $BE_PORT "Backend"
        else
            requirements_met=false
        fi
    fi
    
    if ! check_port $FE_PORT "Frontend"; then
        if [ "${AUTO_KILL_PORTS:-true}" = "true" ]; then
            log "Auto-cleanup enabled. Attempting to free port $FE_PORT..."
            force_kill_port $FE_PORT "Frontend"
        else
            requirements_met=false
        fi
    fi
    
    # Check disk space (minimum 2GB)
    available_space=$(df -h . | awk 'NR==2 {print $4}')
    # Extract numeric value and convert to GB if needed
    space_num=$(echo "$available_space" | sed 's/[^0-9.]//g')
    space_unit=$(echo "$available_space" | sed 's/[0-9.]//g')
    
    # Convert to GB for comparison
    case $space_unit in
        "Ti"|"T") space_gb=$(echo "$space_num * 1024" | bc 2>/dev/null || echo "2048") ;;
        "Gi"|"G") space_gb=$(echo "$space_num" | bc 2>/dev/null || echo "$space_num") ;;
        "Mi"|"M") space_gb=$(echo "$space_num / 1024" | bc -l 2>/dev/null || echo "0.1") ;;
        *) space_gb="2" ;; # Default to 2GB if we can't parse
    esac
    
    if command -v bc >/dev/null 2>&1 && (( $(echo "$space_gb < 2" | bc -l 2>/dev/null || echo "0") )); then
        error "Insufficient disk space. At least 2GB required."
        requirements_met=false
    else
        success "Sufficient disk space available: ${available_space}"
    fi
    
    if [ "$requirements_met" = false ]; then
        error "System requirements not met. Please resolve the issues above."
        exit 1
    fi
    
    success "All system requirements met!"
}

# Update orchestration repository (this repository)
update_orchestration_repo() {
    log "Checking for updates to orchestration system..."
    
    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        warning "Not in a git repository. Skipping orchestration update."
        return
    fi
    
    # Get current branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    if [ "$current_branch" = "HEAD" ]; then
        warning "Detached HEAD state. Skipping orchestration update."
        return
    fi
    
    # Fetch latest changes
    if ! git fetch origin 2>/dev/null; then
        warning "Failed to fetch orchestration updates. Continuing with current version."
        return
    fi
    
    # Check if update is available
    local_commit=$(git rev-parse HEAD)
    remote_commit=$(git rev-parse "origin/$current_branch" 2>/dev/null)
    
    if [ "$local_commit" != "$remote_commit" ] && [ -n "$remote_commit" ]; then
        log "New orchestration updates available. Updating..."
        
        # Check for local changes
        if ! git diff-index --quiet HEAD --; then
            warning "Local changes detected in orchestration. Stashing changes..."
            git stash push -m "Auto-stash before orchestration update $(date)"
        fi
        
        # Pull updates
        if git pull origin "$current_branch"; then
            success "Orchestration system updated successfully!"
            log "Please restart the orchestrator to use the latest version."
            sleep 2
        else
            error "Failed to update orchestration system. Continuing with current version."
        fi
    else
        log "Orchestration system is already up to date"
    fi
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
    
    # Check if dev.sh exists and Docker is available
    if [ -f "dev.sh" ]; then
        log "Found dev.sh script for backend setup"
        chmod +x dev.sh
        
        # Check if Docker is needed and available
        if docker info &> /dev/null; then
            log "Docker available - using dev.sh with Docker"
            ./dev.sh > "../$LOG_DIR/backend-build.log" 2>&1 &
        else
            warning "Docker not running - dev.sh requires Docker"
            log "Falling back to Maven direct execution..."
            
            # Fallback to Maven without Docker
            if [ -f "pom.xml" ]; then
                log "Building backend with Maven (fallback mode)..."
                mvn clean install -DskipTests > "../$LOG_DIR/backend-build.log" 2>&1
                success "Backend build completed"
                
                log "Starting backend server on port 8080..."
                nohup mvn spring-boot:run > "../$LOG_DIR/backend-runtime.log" 2>&1 &
                # Update port for non-Docker mode
                BE_PORT=8080
            else
                error "No pom.xml found for Maven fallback"
                cd ..
                return 1
            fi
        fi
    else
        log "No dev.sh found - using standard Maven commands..."
        mvn clean install -DskipTests > "../$LOG_DIR/backend-build.log" 2>&1
        success "Backend build completed"
        
        log "Starting backend server..."
        nohup mvn spring-boot:run > "../$LOG_DIR/backend-runtime.log" 2>&1 &
        BE_PORT=8080
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
    echo ""
    
    # Wait for backend
    echo -n -e "${BLUE}🔧 Backend health check:${NC} "
    local backend_ready=false
    for i in {1..30}; do
        if curl -s http://localhost:$BE_PORT/actuator/health &> /dev/null || \
           curl -s http://localhost:$BE_PORT/health &> /dev/null || \
           curl -s http://localhost:$BE_PORT &> /dev/null; then
            echo -e "${GREEN}✓ Ready${NC}"
            backend_ready=true
            break
        fi
        
        if [ $i -eq 30 ]; then
            echo -e "${YELLOW}⚠ Timeout${NC}"
            warning "Backend startup timeout. Service may still be starting in background."
            warning "Check logs: $LOG_DIR/backend-runtime.log"
        else
            echo -n "."
            sleep 5
        fi
    done
    
    # Wait for frontend  
    echo -n -e "${BLUE}📱 Frontend health check:${NC} "
    local frontend_ready=false
    for i in {1..20}; do
        if curl -s http://localhost:$FE_PORT &> /dev/null; then
            echo -e "${GREEN}✓ Ready${NC}"
            frontend_ready=true
            break
        fi
        
        if [ $i -eq 20 ]; then
            echo -e "${YELLOW}⚠ Timeout${NC}"
            warning "Frontend startup timeout. Service may still be starting in background."
            warning "Check logs: $LOG_DIR/frontend-runtime.log"
        else
            echo -n "."
            sleep 3
        fi
    done
    
    echo ""
}

# Display detailed service status and URLs
show_status() {
    echo ""
    echo "================================================"
    echo -e "${GREEN}🚀 Motorbike Sharing System is ready!${NC}"
    echo "================================================"
    echo ""
    
    # Check actual service status
    local be_running=false
    local fe_running=false
    
    if lsof -Pi :$BE_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        be_running=true
    fi
    
    if lsof -Pi :$FE_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        fe_running=true
    fi
    
    echo -e "${BLUE}🌐 Service URLs:${NC}"
    echo "   ┌─────────────────────────────────────────────────────"
    
    # Frontend status
    if [ "$fe_running" = true ]; then
        echo -e "   │ ${GREEN}✓${NC} ${BLUE}Frontend:${NC}  http://localhost:$FE_PORT (Running)"
    else
        echo -e "   │ ${RED}✗${NC} ${BLUE}Frontend:${NC}  http://localhost:$FE_PORT (Stopped)"
    fi
    
    # Backend status with detailed endpoints
    if [ "$be_running" = true ]; then
        echo -e "   │ ${GREEN}✓${NC} ${BLUE}Backend:${NC}   http://localhost:$BE_PORT (Running)"
        echo -e "   │   ├─ ${YELLOW}API Docs:${NC}    http://localhost:$BE_PORT/swagger-ui.html"
        echo -e "   │   ├─ ${YELLOW}API Spec:${NC}    http://localhost:$BE_PORT/api-docs"  
        echo -e "   │   └─ ${YELLOW}Health:${NC}      http://localhost:$BE_PORT/actuator/health"
    else
        echo -e "   │ ${RED}✗${NC} ${BLUE}Backend:${NC}   http://localhost:$BE_PORT (Stopped)"
        echo -e "   │   ├─ API Docs:    (unavailable)"
        echo -e "   │   ├─ API Spec:    (unavailable)"
        echo -e "   │   └─ Health:      (unavailable)"
    fi
    
    # Dashboard
    echo -e "   │ ${BLUE}📊 Dashboard:${NC} http://localhost:5001"
    echo "   └─────────────────────────────────────────────────────"
    echo ""
    
    echo -e "${YELLOW}📋 Log Files:${NC}"
    echo "   • Backend build:   $LOG_DIR/backend-build.log"
    echo "   • Backend runtime: $LOG_DIR/backend-runtime.log"
    echo "   • Frontend install: $LOG_DIR/frontend-install.log"
    echo "   • Frontend runtime: $LOG_DIR/frontend-runtime.log"
    echo "   • Orchestrator:    $LOG_DIR/orchestrator.log"
    echo ""
    
    echo -e "${YELLOW}🔧 Management Commands:${NC}"
    echo "   • Stop everything:  ./orchestrator.sh stop (Docker + processes + ports)"
    echo "   • View dashboard:   ./orchestrator.sh dashboard"
    echo "   • Check status:     ./orchestrator.sh status"
    echo "   • View logs:        ./orchestrator.sh logs [backend|frontend|all]"
    echo "   • Restart all:      ./orchestrator.sh restart"
    echo ""
}

# Stop all services (comprehensive: processes + Docker + ports)
stop_services() {
    log "Stopping all services (processes + Docker + ports)..."
    echo ""
    
    # 1. Stop Docker containers if docker-compose.yml exists
    if [ -f "docker-compose.yml" ] && command -v docker &> /dev/null; then
        echo -n -e "${BLUE}🐳 Docker containers:${NC} "
        if docker info &> /dev/null; then
            # Check if containers are running
            local containers=$(docker-compose ps -q 2>/dev/null || echo "")
            if [ -n "$containers" ]; then
                docker-compose down --remove-orphans &> /dev/null
                echo -e "${GREEN}✓ Stopped${NC}"
            else
                echo -e "${YELLOW}⚬ None running${NC}"
            fi
        else
            echo -e "${YELLOW}⚬ Docker not running${NC}"
        fi
    fi
    
    # 2. Stop development processes on specific ports
    echo -n -e "${BLUE}🔧 Development processes:${NC} "
    local stopped_count=0
    
    # Kill processes on project ports
    for port in $BE_PORT $FE_PORT 5001; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            kill $(lsof -Pi :$port -sTCP:LISTEN -t) 2>/dev/null || true
            ((stopped_count++))
        fi
    done
    
    # Kill specific development processes
    if pkill -f "mvn spring-boot:run" 2>/dev/null; then ((stopped_count++)); fi
    if pkill -f "npm start" 2>/dev/null; then ((stopped_count++)); fi
    
    if [ $stopped_count -gt 0 ]; then
        echo -e "${GREEN}✓ Stopped ($stopped_count)${NC}"
    else
        echo -e "${YELLOW}⚬ None running${NC}"
    fi
    
    # 3. Clean additional development ports (merged from clean functionality)
    echo -n -e "${BLUE}🧹 Port cleanup:${NC} "
    local cleaned_count=0
    local common_ports=(3001 4000 4200 5000 5173 8000 8081 9000 9001)
    
    for port in "${common_ports[@]}"; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            kill -9 $(lsof -Pi :$port -sTCP:LISTEN -t) 2>/dev/null || true
            ((cleaned_count++))
        fi
    done
    
    # Kill remaining development processes (be more specific to avoid Docker)
    if pkill -f "npm.*start" 2>/dev/null; then ((cleaned_count++)); fi
    if pkill -f "node.*frontend" 2>/dev/null; then ((cleaned_count++)); fi
    if pkill -f "vite" 2>/dev/null; then ((cleaned_count++)); fi
    if pkill -f "webpack" 2>/dev/null; then ((cleaned_count++)); fi
    
    if [ $cleaned_count -gt 0 ]; then
        echo -e "${GREEN}✓ Cleaned ($cleaned_count ports/processes)${NC}"
    else
        echo -e "${YELLOW}⚬ All clean${NC}"
    fi
    
    # Wait for processes to fully terminate
    sleep 2
    
    echo ""
    success "All services, containers, and ports stopped"
}

# Legacy stop-all function (now alias to stop_services for backward compatibility)
stop_all_services() {
    log "Running comprehensive stop (same as 'stop' command)..."
    stop_services
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
    
    # First update orchestration system itself
    update_orchestration_repo
    
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
    "stop-all"|"clean")
        stop_all_services
        ;;
    "status")
        check_status
        ;;
    "restart")
        stop_services
        sleep 3
        start_orchestration
        ;;
    "clean-restart")
        stop_all_services
        sleep 3
        start_orchestration
        ;;
    "update")
        log "Updating orchestration system and repositories..."
        update_orchestration_repo
        clone_or_update_repo $BE_REPO $BE_DIR
        clone_or_update_repo $FE_REPO $FE_DIR
        success "All repositories updated successfully!"
        ;;
    "dashboard")
        if command -v python3 &> /dev/null; then
            # Setup Python virtual environment if needed
            if [ ! -d "venv" ]; then
                log "Setting up Python virtual environment for dashboard..."
                if [ -f "setup-python-env.sh" ]; then
                    ./setup-python-env.sh
                else
                    log "Creating virtual environment..."
                    python3 -m venv venv
                    source venv/bin/activate
                    pip install --upgrade pip
                    if [ -f "requirements.txt" ]; then
                        pip install -r requirements.txt
                        success "Python dependencies installed"
                    fi
                fi
            fi
            
            # Clear dashboard port if needed
            DASHBOARD_PORT=5001
            if lsof -Pi :$DASHBOARD_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
                log "Clearing port $DASHBOARD_PORT for dashboard..."
                kill -9 $(lsof -Pi :$DASHBOARD_PORT -sTCP:LISTEN -t) 2>/dev/null || true
                sleep 1
            fi
            
            log "Starting dashboard with virtual environment..."
            # Activate venv and start dashboard
            if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
                source venv/Scripts/activate
            else
                source venv/bin/activate
            fi
            python dashboard.py
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
        echo "  start         - Start all services (auto-clears conflicting ports)"
        echo "  stop          - Stop ALL services (Docker containers + processes + ports)"
        echo "  stop-all      - Alias for 'stop' (backward compatibility)"
        echo "  clean         - Alias for 'stop' (backward compatibility)"
        echo "  restart       - Restart all services"
        echo "  clean-restart - Alias for 'restart' (backward compatibility)"
        echo "  update        - Update orchestration system and all repositories"
        echo "  status        - Check service status"
        echo "  dashboard     - Open web dashboard"
        echo "  logs          - View logs [backend|frontend|all]"
        echo "  help          - Show this help message"
        echo ""
        echo "Environment Variables:"
        echo "  AUTO_KILL_PORTS=false - Disable automatic port cleanup (default: true)"
        echo ""
        echo "Python Dashboard:"
        echo "  • Dashboard automatically sets up Python virtual environment (venv/)"
        echo "  • Dependencies installed from requirements.txt"
        echo "  • No system-wide Python package installation"
        ;;
    *)
        error "Unknown command: $1"
        echo "Use '$0 help' for available commands"
        exit 1
        ;;
esac