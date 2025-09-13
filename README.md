# Motorbike Sharing System

A comprehensive full-stack application for motorbike sharing services with automated deployment and management tools.

## Table of Contents

<details>
<summary>Click to expand</summary>

- [Quick Start](#quick-start)
  - [For Complete Beginners](#for-complete-beginners)
  - [For Developers](#for-developers)
  - [For Non-Technical Users](#for-non-technical-users)
- [System Architecture](#system-architecture)
- [Services Overview](#services-overview)
  - [Backend Service](#backend-service)
  - [Frontend Service](#frontend-service)
  - [Database Service](#database-service)
  - [Dashboard Service](#dashboard-service)
  - [Orchestration Service](#orchestration-service)
- [Installation Guide](#installation-guide)
  - [Fresh Machine Setup](#fresh-machine-setup)
  - [Requirements Check](#requirements-check)
- [Usage Guide](#usage-guide)
  - [Starting the System](#starting-the-system)
  - [Stopping the System](#stopping-the-system)
  - [Using the Dashboard](#using-the-dashboard)
  - [Viewing Logs](#viewing-logs)
- [Development Modes](#development-modes)
  - [Docker Mode](#docker-mode)
  - [Direct Mode](#direct-mode)
- [Troubleshooting](#troubleshooting)
- [Advanced Configuration](#advanced-configuration)
- [Contributing](#contributing)

</details>

## Quick Start

### For Complete Beginners

If you have a fresh machine with nothing installed:

```bash
# Step 1: Run the installation script
./install.sh

# Step 2: Start the system
./orchestrator.sh

# Step 3: Open your browser and visit:
# - Frontend: http://localhost:3000
# - Backend API: http://localhost:8080
```

That's it! The system will automatically handle everything else.

### For Developers

```bash
# Start development environment
./orchestrator.sh start

# Open web dashboard for monitoring
./orchestrator.sh dashboard

# View live logs
./orchestrator.sh logs all

# Stop everything when done
./orchestrator.sh stop
```

### For Non-Technical Users

**What This System Does:**
This is a complete motorbike sharing application (like bike-sharing but for motorbikes). It includes:
- A website where users can rent motorbikes
- A backend system that manages all the data
- Everything runs on your computer for development/testing

**Step 1: Get the Code**
```bash
# Open Terminal (macOS) or Command Prompt (Windows)
# Navigate to where you want the project (like Desktop)
cd Desktop

# Download the project
git clone https://github.com/FPTU-Capstone-Project/Repository-Orchestration.git

# Enter the project folder
cd Repository-Orchestration
```

**Step 2: One-Time Setup**
```bash
# Run this only once to install everything needed
./install.sh
```

**Step 3: Start the System**
```bash
# Run this every time you want to use the application
./orchestrator.sh
```

**Step 4: Use the Application**
- Open your web browser
- Go to: `http://localhost:3000` (this is your main app)
- The system runs automatically in the background

**What You'll See:**
- When starting: Lots of text downloading and installing things (this is normal!)
- Success messages like "Frontend is ready!" and "Backend is ready!"
- At the end: Clear instructions with web links
- In your browser: The Motorbike Sharing application interface

**Step 5: Stop When Done**
```bash
# Run this when you're finished
./orchestrator.sh stop
```

**How to Open Terminal/Command Line:**

<details>
<summary>Windows Users</summary>

1. Press `Windows Key + R`
2. Type `cmd` and press Enter
3. A black window opens - this is your command prompt
</details>

<details>
<summary>Mac Users</summary>

1. Press `Cmd + Space` to open Spotlight
2. Type `Terminal` and press Enter
3. A window opens - this is your terminal
</details>

<details>
<summary>If Git is Not Installed</summary>

**Windows:**
- Download Git from: https://git-scm.com/download/win
- Install it with default settings
- Restart Command Prompt

**Mac:**
- Git usually comes pre-installed
- If not, install Xcode Command Line Tools: `xcode-select --install`
</details>

## System Architecture

For detailed system architecture, flow diagrams, and technical documentation, see: [Architecture Documentation](https://github.com/FPTU-Capstone-Project/Repository-Orchestration/blob/master/ARCHITECTURE.md)

## Services Overview

### Backend Service
- **Technology**: Spring Boot (Java)
- **Default Port**: 8080 (Direct mode) / 8081 (Docker mode)  
- **Purpose**: API server from backend repository
- **Management**: Automatically cloned and managed by orchestrator
- **API Documentation**: Available at `/swagger-ui.html` when running
- **Health Check**: Available at `/actuator/health`

### Frontend Service
- **Technology**: React.js
- **Default Port**: 3000
- **Purpose**: Web application from frontend repository
- **Management**: Automatically cloned and managed by orchestrator
- **Development**: Hot-reload enabled for development

### Database Service
- **Technology**: PostgreSQL
- **Default Port**: 5432 (system) / 5433 (Docker development)
- **Purpose**: Data persistence layer
- **Management**: Automatically configured by backend service

### Dashboard Service
- **Technology**: Python Flask
- **Default Port**: 5001
- **Purpose**: Development and monitoring dashboard
- **Features**:
  - Real-time service monitoring
  - Log viewing
  - Git repository management
  - System control interface
  - Service health checks

### Orchestration Service
- **Technology**: Bash scripting
- **Purpose**: Automated system management and deployment
- **Features**:
  - Intelligent service startup/shutdown
  - Docker and direct mode support
  - Port conflict resolution
  - Dependency management
  - Error handling and recovery

## Installation Guide

### Fresh Machine Setup

For a completely new machine without any development tools:

```bash
# The installation script will automatically install:
# - Git (if not present)
# - Node.js and npm
# - Java Development Kit
# - Maven
# - Docker Desktop (optional)
# - Python 3 and pip

./install.sh
```

The installer will:
1. Check your operating system
2. Download and install missing dependencies  
3. Configure the development environment
4. Set up all required tools
5. Test the installation

### Requirements Check

The system will automatically check and install these requirements:

**Essential Requirements:**
- Git (for repository management)
- Node.js 16+ and npm (for frontend)
- Java 17+ (for backend)
- Maven 3.6+ (for backend build)
- Python 3.8+ (for dashboard)

**Optional Requirements:**
- Docker Desktop (for containerized mode)
- PostgreSQL (system installation, optional)

## Usage Guide

### Starting the System

**Simple Start (Recommended):**
```bash
./orchestrator.sh
```

**With Options:**
```bash
# Start with verbose logging
./orchestrator.sh start

# Start and show dashboard
./orchestrator.sh start && ./orchestrator.sh dashboard
```

**What Happens During Startup:**
1. System requirements check
2. Repository updates (pulls latest changes)
3. Dependency installation
4. Service startup (backend then frontend)
5. Health checks
6. Status display

### Stopping the System

**Complete Stop (Recommended):**
```bash
./orchestrator.sh stop
```

This will stop:
- All running services
- Docker containers (if running)
- Development processes
- Clear occupied ports

**Check Status:**
```bash
./orchestrator.sh status
```

### Using the Dashboard

**Start Dashboard:**
```bash
./orchestrator.sh dashboard
```

**Dashboard Features:**
- Real-time service monitoring
- One-click start/stop controls
- Live log viewing
- Repository status
- Direct links to all services
- System health monitoring

**Access Dashboard:**
Open `http://localhost:5001` in your browser

### Viewing Logs

**All Logs:**
```bash
./orchestrator.sh logs all
```

**Specific Service:**
```bash
./orchestrator.sh logs backend
./orchestrator.sh logs frontend
```

**Log Files Location:**
- Backend build: `logs/backend-build.log`
- Backend runtime: `logs/backend-runtime.log`  
- Frontend: `logs/frontend-runtime.log`
- System: `logs/orchestrator.log`

## Development Modes

The system automatically detects and switches between two modes:

### Docker Mode
**When**: Docker Desktop is running
**Backend Port**: 8081
**Features**:
- Isolated containers
- Production-like environment
- Automatic database setup
- Container orchestration

### Direct Mode  
**When**: Docker is not available
**Backend Port**: 8080
**Features**:
- Direct Maven execution
- Faster startup
- Development-friendly
- System resource usage

## Troubleshooting

**For Non-Technical Users:**

<details>
<summary>I Can't Find Terminal/Command Prompt</summary>

**Windows:**
1. Click the Start button
2. Type "cmd" or "Command Prompt"
3. Click on the result that appears
4. A black window should open

**Mac:**
1. Press and hold the `Command` key and press `Space`
2. Type "Terminal"
3. Press Enter
4. A window with white or black background should open
</details>

<details>
<summary>I Get "Command Not Found" or "Git Not Recognized"</summary>

This means Git is not installed on your computer.

**Windows:**
1. Go to https://git-scm.com/download/win
2. Download and install Git with all default options
3. Close and reopen Command Prompt
4. Try the commands again

**Mac:**
1. Run this in Terminal: `xcode-select --install`
2. A popup will appear - click "Install"
3. Wait for it to finish
4. Try the commands again
</details>

<details>
<summary>The Website Won't Open (localhost:3000)</summary>

1. Make sure you ran `./orchestrator.sh` first
2. Wait 2-3 minutes for everything to start
3. Try refreshing your browser
4. If still not working, run `./orchestrator.sh status` to check
</details>

<details>
<summary>I See Lots of Red Text/Errors</summary>

This is usually normal during the first setup. The system installs many things automatically.

1. Wait for the process to complete
2. If it stops and asks for input, just press Enter
3. If you see "SUCCESS" or "ready" messages, everything is working
4. Try accessing the website at `http://localhost:3000`
</details>

<details>
<summary>Everything Looks Frozen/Stuck</summary>

1. Wait 5-10 minutes (first setup takes time)
2. If nothing happens, press `Ctrl+C` to stop
3. Run `./orchestrator.sh stop` to clean up
4. Try `./orchestrator.sh` again
</details>

**For Technical Users:**

**Common Issues and Solutions:**

<details>
<summary>Port Already in Use</summary>

The system automatically handles port conflicts, but if you encounter issues:

```bash
# Stop everything and clear all ports
./orchestrator.sh stop

# Check what's using ports
lsof -i :3000
lsof -i :8080
lsof -i :8081
```
</details>

<details>
<summary>Backend Won't Start</summary>

1. Check if Java is installed: `java -version`
2. Check if Maven is working: `mvn -version`
3. View backend logs: `./orchestrator.sh logs backend`
4. Try Docker mode: Start Docker Desktop and restart
</details>

<details>
<summary>Frontend Build Errors</summary>

1. Clear npm cache: `cd frontend && npm cache clean --force`
2. Delete node_modules: `rm -rf frontend/node_modules`
3. Restart system: `./orchestrator.sh restart`
</details>

<details>
<summary>Dashboard Not Accessible</summary>

1. Check if Python is installed: `python3 --version`
2. Check port 5001: `lsof -i :5001`
3. Restart dashboard: `./orchestrator.sh dashboard`
</details>

**Getting Help:**
```bash
# Show all available commands
./orchestrator.sh help

# Check system status
./orchestrator.sh status
```

## Advanced Configuration

### Environment Variables

```bash
# Disable automatic port cleanup
export AUTO_KILL_PORTS=false
./orchestrator.sh start

# Custom ports (modify orchestrator.sh)
BE_PORT=8082
FE_PORT=3001
```

### Custom Docker Configuration

Edit `docker-compose.yml` for advanced Docker setups:
- Custom network configuration
- Volume mounting
- Environment variables
- Service dependencies

### Development Customization

**Backend Configuration:**
- Modify `backend/src/main/resources/application.properties`
- Custom Maven profiles
- Database connection settings

**Frontend Configuration:**  
- Modify `frontend/package.json`
- Environment-specific builds
- Proxy settings

## Contributing

**Development Workflow:**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `./orchestrator.sh`
5. Submit a pull request

**Repository Structure:**
```
.
├── README.md                 # This file
├── ARCHITECTURE.md          # System architecture
├── install.sh              # Installation script
├── orchestrator.sh          # Main orchestration script
├── dashboard.py            # Web dashboard
├── requirements.txt        # Python dependencies
├── docker-compose.yml      # Docker configuration
├── backend/               # Spring Boot API
├── frontend/             # React application
└── logs/                # Application logs
```

**Coding Standards:**
- Follow existing code style
- Add comments for complex logic
- Update documentation for new features
- Test thoroughly before submitting

---

**System Status:** Production Ready  
**Last Updated:** September 2025  
**Supported Platforms:** macOS, Linux, Windows (WSL)