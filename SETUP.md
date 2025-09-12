# 🚀 Quick Setup Guide

This guide will help you get the Motorbike Sharing System running in under 5 minutes!

## 🎯 For Non-Technical Users

### ⚡ SUPER SIMPLE: Just One Command!
```bash
# 1. Open Terminal (macOS/Linux) or Git Bash (Windows)
# 2. Copy and paste these commands:
git clone https://github.com/FPTU-Capstone-Project/Repository-Orchestration.git
cd Repository-Orchestration
./install.sh

# That's it! The installer does EVERYTHING automatically:
# ✅ Checks your system
# ✅ Installs missing software
# ✅ Downloads the latest code
# ✅ Starts all services
# ✅ Opens your browser
```

### 📱 Access the Application (opens automatically)
- **Frontend**: http://localhost:3000 ← Your main app
- **Backend**: http://localhost:8080 ← API server  
- **Dashboard**: http://localhost:5000 ← Control panel

**No configuration needed! No secrets! No manual setup!** 🎉

---

## 👨‍💻 For Developers

### Quick Development Setup
```bash
git clone https://github.com/FPTU-Capstone-Project/Repository-Orchestration.git
cd Repository-Orchestration

# Start with full monitoring
./orchestrator.sh start
./orchestrator.sh dashboard

# View logs in real-time
./orchestrator.sh logs all
```

### Available Commands
```bash
./orchestrator.sh start     # Start all services
./orchestrator.sh stop      # Stop all services  
./orchestrator.sh restart   # Restart services
./orchestrator.sh status    # Check service status
./orchestrator.sh dashboard # Open web dashboard
./orchestrator.sh logs      # View application logs
./orchestrator.sh help      # Show all commands
```

---

## 🐳 Docker Alternative

If you prefer using Docker:

```bash
# Start with Docker Compose
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

---

## ❓ Need Help?

### Common Issues
- **Port conflicts**: Run `./orchestrator.sh status` to check
- **Missing software**: Run `./scripts/install-deps.sh`
- **Docker not running**: Start Docker Desktop first

### Get Support
1. Check the [README.md](README.md) for detailed documentation
2. Run `./orchestrator.sh help` for command reference
3. Open the dashboard at http://localhost:5000 for visual monitoring

---

**🎉 Welcome to the Motorbike Sharing System! Happy coding! 🚀**