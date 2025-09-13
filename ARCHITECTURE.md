# System Architecture

This document provides a comprehensive overview of the Motorbike Sharing System architecture, data flow, and operational mechanisms.

## Table of Contents

<details>
<summary>Click to expand</summary>

- [System Overview](#system-overview)
- [Architecture Diagram](#architecture-diagram)
- [Service Components](#service-components)
- [Data Flow](#data-flow)
- [Orchestration Mechanism](#orchestration-mechanism)
- [Repository Synchronization](#repository-synchronization)
- [Deployment Modes](#deployment-modes)
- [Communication Patterns](#communication-patterns)
- [Security Architecture](#security-architecture)
- [Monitoring and Logging](#monitoring-and-logging)

</details>

## System Overview

The Motorbike Sharing System is a microservices-based application designed for scalability, maintainability, and ease of deployment. The system automatically synchronizes with the latest code changes from multiple development repositories and provides intelligent orchestration for different deployment scenarios.

### Core Principles

1. **Automated Orchestration**: Single-command deployment and management
2. **Repository Synchronization**: Automatic updates from development repositories
3. **Environment Adaptability**: Smart detection of Docker vs Direct execution modes
4. **Port Management**: Intelligent conflict resolution and service discovery
5. **Health Monitoring**: Comprehensive service health checks and recovery

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Motorbike Sharing System                          │
│                              Full Stack Architecture                        │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   User Access   │    │   Development   │    │   Operations    │
│                 │    │                 │    │                 │
│ Web Browser     │    │ Git Repositories│    │ Orchestration   │
│ Mobile App      │    │ IDE Integration │    │ Monitoring      │
│ API Clients     │    │ Dev Tools       │    │ Logging         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Service Layer                                  │
├─────────────────┬─────────────────┬─────────────────┬─────────────────────┤
│                 │                 │                 │                     │
│  Frontend       │  Backend        │  Database       │  Dashboard          │
│  (React.js)     │  (Spring Boot)  │  (PostgreSQL)   │  (Python Flask)     │
│                 │                 │                 │                     │
│  Port: 3000     │  Port: 8080/1   │  Port: 5432/3   │  Port: 5001         │
│                 │                 │                 │                     │
├─────────────────┼─────────────────┼─────────────────┼─────────────────────┤
│                 │                 │                 │                     │
│ • UI Components │ • REST APIs     │ • Data Storage  │ • Service Monitor   │
│ • State Mgmt    │ • Business Logic│ • Transactions  │ • Log Aggregation   │
│ • Routing       │ • Authentication│ • Migrations    │ • Git Integration   │
│ • HTTP Client   │ • Authorization │ • Backup/Restore│ • Control Interface │
│                 │                 │                 │                     │
└─────────────────┴─────────────────┴─────────────────┴─────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Infrastructure Layer                               │
├─────────────────┬─────────────────┬─────────────────┬─────────────────────┤
│                 │                 │                 │                     │
│ Orchestration   │ Repository Sync │ Health Checks   │ Environment Mgmt    │
│ (Bash Scripts)  │ (Git Automation)│ (HTTP Probes)   │ (Docker/Direct)     │
│                 │                 │                 │                     │
├─────────────────┼─────────────────┼─────────────────┼─────────────────────┤
│                 │                 │                 │                     │
│ • Service Start │ • Auto Fetch    │ • HTTP Health   │ • Docker Detection  │
│ • Port Mgmt     │ • Conflict Res  │ • Service Ready │ • Port Allocation   │
│ • Process Mgmt  │ • Local Changes │ • Retry Logic   │ • Dependency Check  │
│ • Error Handler │ • Branch Sync   │ • Status Report │ • Fallback Modes   │
│                 │                 │                 │                     │
└─────────────────┴─────────────────┴─────────────────┴─────────────────────┘
```

## Service Components

### Frontend Service (React.js)

**Purpose**: User interface and experience layer

**Technology Stack**:
- React.js 18+ with TypeScript
- React Router for navigation
- Axios for HTTP requests
- Tailwind CSS for styling
- React Query for state management

**Key Features**:
- Responsive design for mobile and desktop
- Real-time data updates
- Interactive maps for motorbike locations
- User authentication flows
- Booking and payment interfaces

**Development Flow**:
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Source    │ -> │   Build     │ -> │   Serve     │ -> │   Browser   │
│   Code      │    │   Process   │    │   Content   │    │   Render    │
│             │    │             │    │             │    │             │
│ TypeScript  │    │ Webpack     │    │ Dev Server  │    │ React App   │
│ Components  │    │ Babel       │    │ Hot Reload  │    │ User Inter  │
│ Styles      │    │ PostCSS     │    │ Proxy API   │    │ API Calls   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

### Backend Service (Spring Boot)

**Purpose**: Business logic and API layer

**Technology Stack**:
- Spring Boot 3.x with Java 17+
- Spring Security for authentication
- Spring Data JPA for database operations
- PostgreSQL driver
- Swagger for API documentation

**Key Features**:
- RESTful API endpoints
- JWT-based authentication
- Role-based authorization
- Database transaction management
- Integration with payment services

**API Architecture**:
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  HTTP       │ -> │ Controller  │ -> │  Service    │ -> │ Repository  │
│  Request    │    │  Layer      │    │  Layer      │    │  Layer      │
│             │    │             │    │             │    │             │
│ REST Calls  │    │ Validation  │    │ Business    │    │ Data Access │
│ Auth Header │    │ Mapping     │    │ Logic       │    │ Database    │
│ JSON Data   │    │ Exception   │    │ Processing  │    │ Operations  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

### Database Service (PostgreSQL)

**Purpose**: Data persistence and management

**Key Features**:
- ACID transaction support
- Advanced indexing
- Full-text search capabilities
- JSON data type support
- Backup and recovery mechanisms

**Data Model Overview**:
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    Users    │    │ Motorbikes  │    │  Bookings   │    │  Payments   │
│             │    │             │    │             │    │             │
│ • ID        │<---│ • ID        │<---│ • ID        │<---│ • ID        │
│ • Email     │    │ • Model     │    │ • User ID   │    │ • Booking ID│
│ • Password  │    │ • Location  │    │ • Bike ID   │    │ • Amount    │
│ • Profile   │    │ • Status    │    │ • Start Time│    │ • Status    │
│ • Created   │    │ • Battery   │    │ • End Time  │    │ • Gateway   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

### Dashboard Service (Python Flask)

**Purpose**: Development monitoring and system control

**Technology Stack**:
- Python Flask framework
- Jinja2 templating
- Real-time WebSocket connections
- psutil for system monitoring
- Git integration libraries

**Monitoring Capabilities**:
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   System    │    │   Service   │    │    Git      │    │    User     │
│  Metrics    │ -> │   Health    │ -> │ Repository  │ -> │ Interface   │
│             │    │             │    │             │    │             │
│ CPU Usage   │    │ HTTP Status │    │ Commit Info │    │ Web Dashboard│
│ Memory      │    │ Port Check  │    │ Branch Sync │    │ Controls    │
│ Disk Space  │    │ Log Parsing │    │ Update Detect│   │ Log Viewer  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

## Data Flow

### Request Processing Flow

```
1. User Interaction
   ┌─────────────┐
   │   Browser   │ --> User clicks "Book Motorbike"
   │   (React)   │
   └─────────────┘
           │
           │ HTTP POST /api/bookings
           ▼
2. Frontend Processing
   ┌─────────────┐
   │  React App  │ --> Validates form, adds auth token
   │             │
   └─────────────┘
           │
           │ Authenticated Request
           ▼
3. Backend Processing
   ┌─────────────┐
   │Spring Boot  │ --> Validates JWT, processes business logic
   │   API       │
   └─────────────┘
           │
           │ Database Query
           ▼
4. Database Operation
   ┌─────────────┐
   │ PostgreSQL  │ --> Creates booking record, updates bike status
   │             │
   └─────────────┘
           │
           │ Result Set
           ▼
5. Response Flow
   ┌─────────────┐
   │   Backend   │ --> Returns JSON response
   │             │
   └─────────────┘
           │
           │ JSON Data
           ▼
6. Frontend Update
   ┌─────────────┐
   │   React     │ --> Updates UI state, shows confirmation
   │             │
   └─────────────┘
```

### Repository Synchronization Flow

```
1. Orchestrator Start
   ┌─────────────┐
   │ ./orchestrator.sh
   └─────────────┘
           │
           ▼
2. Repository Check
   ┌─────────────┐
   │ Git Status  │ --> Check local repositories exist
   │ Check       │
   └─────────────┘
           │
           ▼
3. Remote Fetch
   ┌─────────────┐
   │ git fetch   │ --> Fetch latest from origin
   │ origin      │
   └─────────────┘
           │
           ▼
4. Local Changes Detection
   ┌─────────────┐
   │ git diff    │ --> Check for uncommitted changes
   │ --quiet     │
   └─────────────┘
           │
           ▼
5. Conflict Resolution
   ┌─────────────┐
   │ git stash   │ --> Stash local changes if any
   │ push        │
   └─────────────┘
           │
           ▼
6. Update Local
   ┌─────────────┐
   │ git pull    │ --> Pull latest changes
   │ origin      │
   └─────────────┘
           │
           ▼
7. Service Restart
   ┌─────────────┐
   │ Service     │ --> Restart services with new code
   │ Reload      │
   └─────────────┘
```

## Orchestration Mechanism

### Service Lifecycle Management

```
Startup Sequence:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Requirements│ -> │ Repository  │ -> │ Dependencies│ -> │ Services    │
│ Check       │    │ Sync        │    │ Install     │    │ Start       │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
• Java Version      • Git Fetch        • npm install      • Backend Launch
• Maven Install     • Branch Update    • Maven Dependencies • Frontend Start
• Node.js Check     • Stash Changes    • Python pip install • Health Checks
• Docker Status     • Pull Latest      • Dependency Tree   • Port Binding
• Port Availability • Conflict Resolve • Cache Management  • Service Ready
```

### Health Check System

```
Health Check Flow:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ HTTP Probe  │ -> │ Retry Logic │ -> │ Status      │ -> │ Action      │
│             │    │             │    │ Report      │    │ Decision    │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
• GET /health       • Max 30 retries   • Service Ready    • Continue Flow
• 5 sec interval    • Exponential      • Service Down     • Retry Service
• Timeout 10s       • Backoff          • Service Timeout  • Report Error
• Connection Test   • Circuit Breaker  • Partial Ready    • Fallback Mode
```

## Deployment Modes

### Docker Mode (Production-like)

**When Active**: Docker Desktop is running and available

```
Docker Mode Architecture:
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Docker Environment                             │
├─────────────────┬─────────────────┬─────────────────┬─────────────────────┤
│  Frontend       │  Backend        │  Database       │  Reverse Proxy      │
│  Container      │  Container      │  Container      │  (Nginx)            │
│                 │                 │                 │                     │
│ Node:18-alpine  │ openjdk:17-jre  │ postgres:15     │ nginx:alpine        │
│ Port: 3000      │ Port: 8081      │ Port: 5433      │ Port: 80/443        │
│                 │                 │                 │                     │
├─────────────────┼─────────────────┼─────────────────┼─────────────────────┤
│                 │                 │                 │                     │
│ • npm build     │ • mvn package   │ • initdb        │ • SSL termination   │
│ • serve static  │ • java -jar     │ • volume mount  │ • load balancing    │
│ • hot reload    │ • health check  │ • backup script │ • request routing   │
│                 │                 │                 │                     │
└─────────────────┴─────────────────┴─────────────────┴─────────────────────┘
                                      │
                                      ▼
                        ┌─────────────────────────────┐
                        │     Docker Network          │
                        │   (motorbike-network)       │
                        │                             │
                        │ • Container discovery       │
                        │ • Internal DNS resolution   │
                        │ • Network isolation         │
                        │ • Volume management         │
                        └─────────────────────────────┘
```

### Direct Mode (Development-friendly)

**When Active**: Docker is not available or disabled

```
Direct Mode Architecture:
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Host System Environment                          │
├─────────────────┬─────────────────┬─────────────────┬─────────────────────┤
│  Frontend       │  Backend        │  Database       │  Dashboard          │
│  Process        │  Process        │  (External)     │  Process            │
│                 │                 │                 │                     │
│ npm start       │ mvn spring-boot │ System Postgres │ python dashboard.py │
│ Port: 3000      │ Port: 8080      │ Port: 5432      │ Port: 5001          │
│                 │                 │                 │                     │
├─────────────────┼─────────────────┼─────────────────┼─────────────────────┤
│                 │                 │                 │                     │
│ • Webpack dev   │ • Direct JVM    │ • Local install │ • Flask dev server  │
│ • Hot module    │ • Auto restart  │ • Shared access │ • Real-time monitor │
│ • Fast build    │ • Debug ports   │ • Manual setup  │ • Log aggregation   │
│                 │                 │                 │                     │
└─────────────────┴─────────────────┴─────────────────┴─────────────────────┘
                                      │
                                      ▼
                        ┌─────────────────────────────┐
                        │      Host Networking        │
                        │                             │
                        │ • localhost access          │
                        │ • Port management           │
                        │ • Process isolation         │
                        │ • Shared file system        │
                        └─────────────────────────────┘
```

## Communication Patterns

### API Communication

```
Frontend to Backend Communication:
┌─────────────┐                    ┌─────────────┐
│  React App  │                    │Spring Boot  │
│             │                    │   API       │
│ ┌─────────┐ │  HTTP/JSON/REST    │ ┌─────────┐ │
│ │API Layer│ │ ----------------> │ │Controller│ │
│ │         │ │                    │ │  Layer  │ │
│ │ • Auth  │ │                    │ │         │ │
│ │ • HTTP  │ │ <---------------- │ │ • Valid │ │
│ │ • Cache │ │   JSON Response    │ │ • Auth  │ │
│ └─────────┘ │                    │ │ • Serialize│
└─────────────┘                    │ └─────────┘ │
                                   └─────────────┘

API Endpoint Examples:
• POST /api/auth/login        --> User authentication
• GET  /api/motorbikes        --> List available bikes
• POST /api/bookings          --> Create new booking
• PUT  /api/bookings/{id}     --> Update booking
• GET  /api/users/profile     --> User profile data
```

### Database Communication

```
Backend to Database Communication:
┌─────────────┐                    ┌─────────────┐
│Spring Boot  │                    │ PostgreSQL  │
│             │                    │  Database   │
│ ┌─────────┐ │   JDBC/SQL         │ ┌─────────┐ │
│ │JPA Repos│ │ ----------------> │ │ Tables  │ │
│ │         │ │                    │ │         │ │
│ │ • CRUD  │ │                    │ │ • Users │ │
│ │ • Query │ │ <---------------- │ │ • Bikes │ │
│ │ • TX    │ │    Result Sets     │ │ • Books │ │
│ └─────────┘ │                    │ └─────────┘ │
└─────────────┘                    └─────────────┘

Query Flow:
1. Service calls repository method
2. JPA translates to SQL query
3. PostgreSQL executes query
4. Result set returned to JPA
5. Entities mapped to Java objects
6. Data returned to service layer
```

## Security Architecture

### Authentication Flow

```
JWT Authentication Flow:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Login     │ -> │  Validate   │ -> │  Generate   │ -> │   Store     │
│   Request   │    │ Credentials │    │    JWT      │    │   Token     │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
• User submits      • Check password    • Create token      • Client storage
• Email/password    • Hash comparison   • Sign with secret  • Local storage
• Form validation   • User verification • Set expiration    • Secure cookie
• HTTPS transport   • Account status    • Include claims    • Auto-refresh
```

### Authorization Model

```
Role-Based Access Control:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    User     │    │   Admin     │    │ Super Admin │
│             │    │             │    │             │
│ • View bikes│    │ • Add bikes │    │ • User mgmt │
│ • Book rides│    │ • Edit bikes│    │ • System cfg│
│ • View hist │    │ • View logs │    │ • Analytics │
│ • Update    │    │ • Reports   │    │ • Monitoring│
│   profile   │    │ • Moderate  │    │ • Backup    │
└─────────────┘    └─────────────┘    └─────────────┘
```

## Monitoring and Logging

### Log Aggregation System

```
Logging Architecture:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Service    │ -> │  Log Files  │ -> │ Aggregator  │ -> │  Dashboard  │
│  Logs       │    │             │    │             │    │  Viewer     │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
• Application       • File rotation     • Log parsing      • Real-time view
• Error logs        • Size management   • Filter/search    • Log levels
• Access logs       • Retention policy  • Pattern matching • Download logs
• Debug info        • Backup strategy   • Alert triggers   • Export options
```

### Performance Metrics

```
Monitoring Metrics:
┌─────────────────────────────────────────────────────────────────────────────┐
│                            System Metrics                                   │
├─────────────────┬─────────────────┬─────────────────┬─────────────────────┤
│   Application   │    System       │   Database      │     Network         │
│   Metrics       │    Metrics      │   Metrics       │     Metrics         │
│                 │                 │                 │                     │
│ • Response time │ • CPU usage     │ • Query time    │ • Request rate      │
│ • Error rate    │ • Memory usage  │ • Connection    │ • Response time     │
│ • Throughput    │ • Disk I/O      │   pool size     │ • Error rate        │
│ • Active users  │ • Network I/O   │ • Lock waits    │ • Bandwidth usage   │
│ • API calls     │ • Load average  │ • Dead locks    │ • Connection count  │
└─────────────────┴─────────────────┴─────────────────┴─────────────────────┘
```

This architecture ensures a robust, scalable, and maintainable system that can adapt to different deployment scenarios while providing comprehensive monitoring and automated management capabilities.