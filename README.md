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

### 🚀 COMPLETELY NEW MACHINE (Zero Setup)

**ONE COMMAND for everything from scratch:**

```bash
# Download and run the complete setup (requires only basic terminal)
curl -fsSL https://raw.githubusercontent.com/FPTU-Capstone-Project/Repository-Orchestration/main/quick-setup.sh | bash
```

**What this does:**
- Installs ALL requirements (Git, Docker, Node.js, Java, Maven, Python)
- Downloads the project
- Starts everything automatically
- Works on macOS, Linux, and Windows (Git Bash)

**That's it! 🎉** Your system will be running in ~10-15 minutes.

---

### 🛠️ IF YOU ALREADY HAVE BASIC TOOLS

**Prerequisites REQUIRED:**
- Git
- Docker Desktop (MUST be running)
- Node.js 16+
- Java 17+
- Maven 3.6+
- Python 3.8+

**Quick Setup:**
```bash
# Download the project
git clone https://github.com/FPTU-Capstone-Project/Repository-Orchestration.git
cd Repository-Orchestration

# Make scripts runnable
chmod +x *.sh

# Start everything (auto-installs what's missing)
./orchestrator.sh
```

---

### 📱 For Non-Technical Users

**What This System Does:**
Complete motorbike sharing application that runs on your computer:
- Website for renting motorbikes
- Backend system for data management  
- Database for storing information
- Everything isolated and safe

**Method 1: Super Easy (Recommended)**
```bash
# Copy-paste this ONE command in Terminal:
curl -fsSL https://raw.githubusercontent.com/FPTU-Capstone-Project/Repository-Orchestration/main/quick-setup.sh | bash
```

**Method 2: Step by Step**
1. Download project manually from GitHub
2. Open Terminal/Command Prompt in project folder
3. Run: `chmod +x *.sh`
4. Run: `./orchestrator.sh`

**Access Your Application:**
- Website: `http://localhost:3000`
- Admin Panel: `http://localhost:5001`

**Stop Everything:**
```bash
./orchestrator.sh stop
```

**IMPORTANT: Setup Required for Different Operating Systems:**

<details>
<summary>Windows Users - Setup Required</summary>

**Windows Command Prompt CANNOT run bash scripts. You need ONE of these options:**

**Option 1: Git Bash (Recommended for beginners)**
1. Download Git from: https://git-scm.com/download/win
2. During installation, make sure to select "Git Bash Here"
3. After installation, right-click in any folder → "Git Bash Here"
4. This opens a terminal that can run bash scripts

**Option 2: Windows Subsystem for Linux (WSL)**
1. Open PowerShell as Administrator
2. Run: `wsl --install`
3. Restart your computer
4. Open "Ubuntu" or "WSL" from Start menu
5. This gives you a full Linux terminal

**How to access:**
- Git Bash: Right-click in folder → "Git Bash Here"
- WSL: Search "Ubuntu" or "WSL" in Start menu
</details>

<details>
<summary>Mac Users - Ready to Use</summary>

1. Press `Cmd + Space` to open Spotlight
2. Type `Terminal` and press Enter
3. A window opens - this is your terminal
4. Mac has bash/zsh built-in, ready to use!
</details>

<details>
<summary>Linux Users - Ready to Use</summary>

1. Press `Ctrl + Alt + T` (most distributions)
2. Or search "Terminal" in applications
3. Linux has bash built-in, ready to use!
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
  - Automatic system updates

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
- All project-related services
- Docker containers (but NOT Docker Engine itself)
- Development processes (Maven, npm, etc.)
- Clear occupied ports

**Note:** Docker Desktop/Engine remains running - only project containers are stopped.

**Check Status:**
```bash
./orchestrator.sh status
```

### Updating the System

**Get Latest Updates:**
```bash
./orchestrator.sh update
```

This will:
- Update the orchestration system itself (this repository)
- Pull latest changes from backend and frontend repositories
- Keep all your local data intact

**Note:** The system also automatically checks for orchestration updates when you run `./orchestrator.sh start`

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

## Development Architecture

This system is designed for **Docker-only local development**:

### Full Docker Stack
**Requirements**: Docker Desktop MUST be running
**Architecture**:
- **PostgreSQL Database**: Isolated container on port 5433
- **Backend API**: Spring Boot container on port 8081  
- **Frontend**: React dev server on port 3000
- **Dashboard**: Python Flask on port 5001

**Benefits**:
- ✅ **Consistent environment** across all machines
- ✅ **Isolated data** - won't conflict with system PostgreSQL
- ✅ **Easy reset** - just restart containers
- ✅ **Production-like** setup for development
- ✅ **Team consistency** - everyone uses identical setup

**No Fallback Modes**: This ensures all developers have the same experience and prevents environment-related bugs.

## Troubleshooting

**For Non-Technical Users:**

<details>
<summary>The ONE-COMMAND Setup Failed</summary>

**Most common issues:**

1. **No Terminal/Command Prompt access:**
   - Windows: Press Windows Key, type "cmd", press Enter
   - Mac: Press Cmd+Space, type "Terminal", press Enter

2. **"curl command not found":**
   - Download the project manually from GitHub
   - Follow Method 2 in the instructions above

3. **Permission denied:**
   - Try running: `chmod +x quick-setup.sh && ./quick-setup.sh`
</details>

<details>
<summary>Docker Issues</summary>

**"Docker is REQUIRED" error:**
1. Docker Desktop is not installed or not running
2. Install Docker Desktop for your OS:
   - Mac: https://desktop.docker.com/mac/main/amd64/Docker.dmg
   - Windows: https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe
   - Linux: Follow https://docs.docker.com/engine/install/
3. Start Docker Desktop and wait for green status
4. Try again

**IMPORTANT:** Docker Desktop MUST be running before starting the project.
</details>

<details>
<summary>Stop Command Kills Docker</summary>

**Issue:** Running `./orchestrator.sh stop` turns off Docker Desktop completely.

**This is fixed!** The latest version only stops project containers, not Docker Engine.

**If you still have this issue:**
1. Update the orchestrator: `git pull` in the project folder
2. Docker Desktop should stay running after stop
</details>

<details>
<summary>Website Won't Open (localhost:3000)</summary>

1. **Check Docker is running:** Look for Docker Desktop in system tray
2. **Wait longer:** First startup takes 3-5 minutes
3. **Check status:** Run `./orchestrator.sh status`
4. **Check ports:** Make sure nothing else is using port 3000
5. **Restart everything:** `./orchestrator.sh stop` then `./orchestrator.sh`
</details>

<details>
<summary>Lots of Red Text/Error Messages</summary>

**This is usually NORMAL during setup!**

Red text during installation means:
- Downloading and installing dependencies
- Building Docker containers
- Setting up databases

**Only worry if:**
- The process completely stops
- You see "FAILED" or "ERROR" at the end
- No "SUCCESS" messages appear

**If stuck:** Wait 10 minutes, then restart
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