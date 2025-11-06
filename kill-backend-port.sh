#!/bin/bash

# Quick script to kill any process using port 8080 (Backend port)
# Useful when backend crashes or doesn't shutdown properly

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PORT=8080

echo -e "${YELLOW}Checking port $PORT...${NC}"

if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${YELLOW}Port $PORT is occupied. Cleaning up...${NC}"
    
    # Show what's using the port
    echo ""
    echo "Processes using port $PORT:"
    lsof -Pi :$PORT -sTCP:LISTEN
    echo ""
    
    # Kill all processes
    local pids=$(lsof -Pi :$PORT -sTCP:LISTEN -t)
    for pid in $pids; do
        echo -e "Killing process ${RED}$pid${NC}..."
        kill -9 $pid 2>/dev/null || true
    done
    
    sleep 1
    
    # Verify port is free
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${RED}Failed to free port $PORT${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ Port $PORT is now free${NC}"
        exit 0
    fi
else
    echo -e "${GREEN}✓ Port $PORT is already free${NC}"
    exit 0
fi
