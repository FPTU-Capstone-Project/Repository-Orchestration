# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a **motorbike sharing system** with automated deployment orchestration. The system consists of:

- **Backend**: Spring Boot 3.4+ (Java 17) REST API with PostgreSQL, Redis, JWT auth, wallet system, and PayOS payment integration
- **Frontend**: React 19+ TypeScript SPA with Tailwind CSS, lazy loading, and modern UI components
- **Database**: PostgreSQL with Flyway migrations, Redis for caching
- **Dashboard**: Python Flask development monitoring interface 
- **Orchestration**: Bash-based automation for Docker deployment, repository synchronization, and service management

The orchestrator automatically clones and manages two external repositories:
- Backend: `https://github.com/FPTU-Capstone-Project/MotorbikeSharingSystem_BE.git`
- Frontend: `https://github.com/FPTU-Capstone-Project/MotorbikeSharingSystem_FE.git`

## Core Commands

All development commands are managed through the main orchestrator script:

```bash
# Start all services (most common command)
./orchestrator.sh

# Alternative commands
./orchestrator.sh start          # Start all services
./orchestrator.sh stop           # Stop all services and containers
./orchestrator.sh restart        # Restart all services
./orchestrator.sh status         # Check service status
./orchestrator.sh dashboard      # Launch Python Flask monitoring dashboard
./orchestrator.sh update         # Update repositories and orchestration system
./orchestrator.sh logs [backend|frontend|all]  # View service logs
./orchestrator.sh help           # Show all available commands
```

### Component-Specific Commands

**Backend (Spring Boot + Maven)**:
- Maven build: `mvn clean install -DskipTests` (in backend/ directory)
- Run backend: `mvn spring-boot:run`
- Tests: `mvn test`

**Frontend (React + npm)**:
- Install dependencies: `npm install` (in frontend/ directory)
- Development server: `npm start`
- Build for production: `npm run build`
- Tests: `npm test`

**Dashboard (Python Flask)**:
- Setup virtual env: `python3 -m venv venv && source venv/bin/activate`
- Install dependencies: `pip install -r requirements.txt`
- Run dashboard: `python dashboard.py`

## Development Workflow

### Docker-First Development
The system is designed for Docker-first local development:
- **Database**: PostgreSQL 13 container on port 5432
- **Backend**: Spring Boot container on port 8080 
- **Frontend**: React dev server on port 3000
- **Dashboard**: Flask server on port 5000
- **Cache**: Redis container on port 6379

All services communicate via Docker network `motorbike-network`.

### Repository Management
The orchestrator handles automatic repository synchronization:
1. Fetches latest changes from origin
2. Stashes local changes if any exist
3. Pulls updates and restarts affected services
4. Maintains git history and handles conflicts

### Service Ports
- Backend API: `8080` (Docker) / `8081` (Direct mode)
- Frontend: `3000`
- Database: `5432` (system) / `5433` (Docker dev)
- Dashboard: `5000`
- Redis: `6379`

## Key Architecture Patterns

### Backend (Spring Boot)
- **Package structure**: `com.mssus.app` with domain-driven design
- **Key components**: Controllers, Services, Repositories, DTOs, Entities
- **Security**: JWT authentication with Spring Security
- **Database**: JPA/Hibernate with Flyway migrations
- **APIs**: RESTful endpoints with Swagger/OpenAPI documentation
- **Wallet system**: Complex financial transaction handling with audit trails
- **Payment integration**: PayOS for Vietnamese payment processing

### Frontend (React)
- **Architecture**: Component-based with lazy loading for performance
- **State management**: React hooks and context
- **Styling**: Tailwind CSS with responsive design
- **Routing**: React Router for SPA navigation
- **Performance**: Code splitting, lazy loading, performance optimization components
- **UI**: Modern admin dashboard with analytics, user management, payment tracking

### Database Schema
Core entities include:
- User management (accounts, profiles, verification)
- Vehicle management (motorbikes, status tracking)
- Wallet system (transactions, payments, audit)
- Booking system (rides, shared rides, payments)
- Safety features (SOS alerts, driver verification)

## Development Notes

### Running Tests
- Backend: `mvn test` (JUnit + Spring Boot Test)
- Frontend: `npm test` (Jest + Testing Library)
- No specific test commands in orchestrator - use component-specific commands

### Debugging
- Backend logs: `logs/backend-runtime.log`
- Frontend logs: `logs/frontend-runtime.log`
- System logs: `logs/orchestrator.log`
- Dashboard provides real-time log viewing

### Environment Configuration
- Default configuration works out-of-the-box
- Optional customization via `.env` file (copy from `.env.example`)
- Database credentials: `admin/admin123` for development
- All repositories are public - no authentication needed

### Health Checks
- Backend: `/actuator/health` endpoint
- Frontend: HTTP probe on port 3000
- Automatic retry logic with 30-second intervals

### Port Conflict Resolution
The orchestrator automatically handles port conflicts by:
1. Detecting processes using required ports
2. Stopping conflicting services
3. Cleaning up Docker containers
4. Ensuring clean startup

This system prioritizes development consistency and ease of use through comprehensive automation while maintaining production-ready architecture patterns.