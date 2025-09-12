# 🏍️ Motorbike Sharing System - Orchestration Repository

**One-click deployment for the complete Motorbike Sharing System**

This repository provides a comprehensive orchestration solution that allows developers, non-technical users, and stakeholders to run the entire Motorbike Sharing System (Frontend + Backend) with a single command, while automatically staying up-to-date with the latest changes from development teams.

## 🚀 Quick Start

### ⚡ Super Simple - One Command Setup
```bash
# 1. Download this repository
git clone https://github.com/FPTU-Capstone-Project/Repository-Orchestration.git
cd Repository-Orchestration

# 2. Run ONE command - that's it! 
./install.sh

# The installer will:
# ✅ Check your system
# ✅ Install missing dependencies automatically
# ✅ Start all services
# ✅ Open the application in your browser
```

### 🎯 Alternative: Manual Steps
```bash
# If you prefer manual control:
git clone https://github.com/FPTU-Capstone-Project/Repository-Orchestration.git
cd Repository-Orchestration

# Start everything with auto-install
./orchestrator.sh

# Access the applications:
# Frontend: http://localhost:3000
# Backend: http://localhost:8080  
# Dashboard: http://localhost:5000
```

### 👨‍💻 For Developers
```bash
# Full development setup
git clone https://github.com/FPTU-Capstone-Project/Repository-Orchestration.git
cd Repository-Orchestration

# Start with monitoring dashboard
./orchestrator.sh start
./orchestrator.sh dashboard

# View real-time logs  
./orchestrator.sh logs all
```

## 📋 Features

### 🔧 Smart Environment Detection
- **Automatic Prerequisites Check**: Verifies Java, Node.js, Maven, Docker, and Git
- **Port Conflict Resolution**: Detects and reports port conflicts before starting
- **Dependency Validation**: Ensures all required tools are installed and up-to-date
- **Docker Status Monitoring**: Checks if Docker is running and accessible

### 🔄 Automatic Updates
- **Git Integration**: Automatically fetches latest changes from both repositories
- **Smart Stashing**: Preserves local changes when pulling updates
- **Version Tracking**: Shows current commit information for both frontend and backend
- **Update Notifications**: Dashboard displays when new changes are available

### 📊 Web Dashboard
- **Real-time Monitoring**: Live status of all services
- **One-click Controls**: Start, stop, and restart services from the web interface
- **Log Viewer**: Browse logs from all services in real-time
- **Commit History**: View latest changes from development teams
- **Health Checks**: Automatic service health monitoring

### 🎯 Multi-Environment Support
- **Development Mode**: Full debugging and hot-reload capabilities
- **Production Mode**: Optimized builds and performance monitoring  
- **Docker Compose**: Containerized deployment with orchestration
- **Hybrid Mode**: Mix of local development and containerized services

## 🛠️ System Requirements

### Minimum Requirements
- **OS**: macOS, Linux, or Windows with WSL2
- **RAM**: 4GB (8GB recommended)
- **Storage**: 2GB available space
- **Network**: Internet connection for initial setup

### Required Software
```bash
# ✨ NO MANUAL INSTALLATION NEEDED! ✨
# The installer automatically checks and installs:
- Git (2.0+)           ← Installs automatically
- Node.js (16.0+)      ← Installs automatically  
- npm (8.0+)           ← Comes with Node.js
- Java (11+)           ← Installs automatically
- Maven (3.6+)         ← Installs automatically
- Docker (20.0+)       ← Optional (installs if possible)
- Python 3.7+         ← Optional (for dashboard)
```

## 📖 Usage Guide

### Basic Commands

```bash
# Start all services (default command)
./orchestrator.sh start
./orchestrator.sh  # Same as 'start'

# Stop all services
./orchestrator.sh stop

# Restart all services
./orchestrator.sh restart

# Check service status
./orchestrator.sh status

# Open web dashboard
./orchestrator.sh dashboard

# View logs
./orchestrator.sh logs [backend|frontend|all]

# Show help
./orchestrator.sh help
```

### Web Dashboard Features

Access the dashboard at `http://localhost:5000` to:

- **Monitor Services**: Real-time status of Frontend, Backend, and Database
- **Control Services**: Start/stop services with one click
- **View Logs**: Real-time log streaming from all services
- **Check Updates**: See latest commits and pull new changes
- **Health Monitoring**: Automatic health checks and alerts

## 🏗️ Architecture

### Repository Structure
```
Repository-Orchestration/
├── orchestrator.sh          # Main orchestration script
├── dashboard.py            # Web dashboard application
├── docker-compose.yml      # Container orchestration
├── requirements.txt        # Python dependencies
├── .env.example           # Environment configuration
├── nginx/                 # Reverse proxy config
├── logs/                  # Application logs
│   ├── orchestrator.log
│   ├── backend-build.log
│   ├── backend-runtime.log
│   ├── frontend-install.log
│   └── frontend-runtime.log
├── backend/              # Auto-cloned BE repository
└── frontend/             # Auto-cloned FE repository
```

### Service Architecture
```
┌─────────────────────────────────────────────────────────┐
│                    Nginx (Port 80)                     │
│                 Reverse Proxy & SSL                    │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────┼───────────────────────────────┐
│                         │                               │
│  Frontend (Port 3000)   │   Backend (Port 8080)        │
│  React TypeScript       │   Spring Boot Java            │
│                         │                               │
└─────────────────────────┼───────────────────────────────┘
                          │
┌─────────────────────────┼───────────────────────────────┐
│                         │                               │
│  Database (Port 5432)   │   Dashboard (Port 5000)      │
│  PostgreSQL             │   Python Flask                │
│                         │                               │
└─────────────────────────┴───────────────────────────────┘
```

## 🚦 Different Usage Scenarios

### 1. Non-Technical Users (Stakeholders, QA, etc.)
```bash
# One-time setup
git clone https://github.com/FPTU-Capstone-Project/Repository-Orchestration.git
cd Repository-Orchestration
./orchestrator.sh

# Daily usage - just open the dashboard
./orchestrator.sh dashboard
# Then use web interface for all controls
```

### 2. Developers - Quick Testing
```bash
# Get latest code and run
./orchestrator.sh start

# Make changes in ./backend or ./frontend directories
# Services will auto-reload with changes

# View logs for debugging
./orchestrator.sh logs backend
```

### 3. DevOps - Production Deployment
```bash
# Use Docker Compose for production
docker-compose up -d

# Monitor all services
docker-compose logs -f

# Scale services as needed
docker-compose up -d --scale backend=2
```

### 4. CI/CD Integration
```bash
# Automated testing pipeline
./orchestrator.sh start
sleep 30  # Wait for services to be ready
npm run test:e2e
./orchestrator.sh stop
```

## 🔧 Configuration

### Environment Variables
Copy `.env.example` to `.env` and customize:

```env
# Repository URLs (usually don't change)
BE_REPO=https://github.com/FPTU-Capstone-Project/MotorbikeSharingSystem_BE.git
FE_REPO=https://github.com/FPTU-Capstone-Project/MotorbikeSharingSystem_FE.git

# Service Ports (change if conflicts)
BE_PORT=8080
FE_PORT=3000
DASHBOARD_PORT=5000

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=motorbike_sharing
DB_USER=admin
DB_PASSWORD=admin123
```

### Custom Scripts
You can override default behavior by creating:

- `scripts/pre-start.sh` - Runs before starting services
- `scripts/post-start.sh` - Runs after services are ready
- `scripts/custom-build.sh` - Custom build process
- `config/local.yml` - Local configuration overrides

## 🐛 Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Check what's using the port
lsof -i :8080
lsof -i :3000

# Kill processes if needed
./orchestrator.sh stop

# Or change ports in .env file
```

#### Docker Not Running
```bash
# Start Docker Desktop
open -a Docker

# Or start Docker service on Linux
sudo systemctl start docker
```

#### Java Version Issues
```bash
# Check Java version
java -version

# Install Java 11 or higher
# On macOS: brew install openjdk@11
# On Ubuntu: sudo apt install openjdk-11-jdk
```

#### Node.js/npm Issues
```bash
# Check versions
node --version
npm --version

# Update if needed
npm install -g npm@latest

# Or use nvm to manage Node versions
nvm install 18
nvm use 18
```

### Log Analysis
```bash
# View all logs in real-time
./orchestrator.sh logs all

# Check specific service logs
./orchestrator.sh logs backend
./orchestrator.sh logs frontend

# View orchestrator logs for system issues
tail -f logs/orchestrator.log
```

### Getting Help
```bash
# Built-in help
./orchestrator.sh help

# Check service status
./orchestrator.sh status

# Open dashboard for visual monitoring
./orchestrator.sh dashboard
```

## 🔐 Security Considerations

### Development Environment
- All services run on localhost by default
- Default passwords should be changed for production
- HTTPS is configured but uses self-signed certificates

### Production Deployment
- Use environment variables for sensitive data
- Configure proper SSL certificates
- Set up database authentication
- Enable firewall rules
- Regular security updates

## 🚀 Advanced Features

### Auto-Pull Updates
The orchestrator can automatically check for and pull updates:

```bash
# Enable auto-updates (runs every hour)
echo "0 * * * * cd /path/to/Repository-Orchestration && ./orchestrator.sh start" | crontab -

# Manual update check
./orchestrator.sh start  # Will pull latest changes automatically
```

### Custom Hooks
Create custom hooks for deployment workflow:

```bash
# Pre-start hook
cat > scripts/pre-start.sh << 'EOF'
#!/bin/bash
echo "Running custom pre-start tasks..."
# Add your custom logic here
EOF

chmod +x scripts/pre-start.sh
```

### Monitoring & Alerts
```bash
# Set up monitoring endpoints
curl http://localhost:5000/api/status
curl http://localhost:8080/actuator/health
curl http://localhost:3000/health

# Integration with monitoring tools
# Prometheus endpoint: http://localhost:5000/metrics
# Health checks: http://localhost:5000/api/health
```

## 🤝 Contributing

### For the Orchestration Repository
1. Fork this repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and test them
4. Commit: `git commit -m 'Add amazing feature'`
5. Push: `git push origin feature/amazing-feature`
6. Open a Pull Request

### For Backend/Frontend Changes
The orchestration repository automatically pulls from:
- Backend: `https://github.com/FPTU-Capstone-Project/MotorbikeSharingSystem_BE.git`
- Frontend: `https://github.com/FPTU-Capstone-Project/MotorbikeSharingSystem_FE.git`

Changes in these repositories will be automatically available to all users of the orchestration system.

## 📞 Support

### Getting Help
1. **Check the logs**: `./orchestrator.sh logs all`
2. **Run diagnostics**: `./orchestrator.sh status`
3. **Open web dashboard**: `./orchestrator.sh dashboard`
4. **Check system requirements**: Script will validate automatically

### Issue Reporting
- **Orchestration Issues**: Create issue in this repository
- **Backend Issues**: Report to [MotorbikeSharingSystem_BE](https://github.com/FPTU-Capstone-Project/MotorbikeSharingSystem_BE)
- **Frontend Issues**: Report to [MotorbikeSharingSystem_FE](https://github.com/FPTU-Capstone-Project/MotorbikeSharingSystem_FE)

### Contact Information
- **Project Team**: FPTU Capstone Project Team
- **Organization**: [FPTU-Capstone-Project](https://github.com/FPTU-Capstone-Project)

---

## 📄 License

This orchestration repository is part of the FPTU Capstone Project. Please refer to individual component repositories for their specific licenses.

---

**🎉 Happy Developing! 🚀**

*This orchestration system is designed to make your development workflow smooth and your deployments reliable. Whether you're a developer working on features or a stakeholder reviewing the latest changes, everything you need is just one command away!*