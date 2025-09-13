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

1. **Installation**: Double-click or run `./install.sh` once
2. **Start**: Run `./orchestrator.sh` whenever you want to use the system
3. **Access**: Open your web browser to `http://localhost:3000`
4. **Stop**: Run `./orchestrator.sh stop` when finished

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