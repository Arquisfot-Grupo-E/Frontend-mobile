#!/bin/bash

# Script to run Flutter mobile app with GraphQL connection
# This script handles emulator startup, port forwarding, and app launch

set -e  # Exit on error

echo "🚀 Starting Flutter Mobile App Setup..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if GraphQL server is running
echo -e "\n${YELLOW}📡 Checking GraphQL server...${NC}"
if curl -s -X POST http://localhost:4000/graphql \
    -H "Content-Type: application/json" \
    -d '{"query":"{ __typename }"}' > /dev/null 2>&1; then
    echo -e "${GREEN}✓ GraphQL server is running at http://localhost:4000${NC}"
else
    echo -e "${RED}✗ GraphQL server is not running!${NC}"
    echo -e "${YELLOW}Starting GraphQL gateway...${NC}"
    cd /home/manolo/2025-II/project/middleware/Middleware-Graphql
    docker-compose up -d
    cd - > /dev/null
    sleep 3
    echo -e "${GREEN}✓ GraphQL server started${NC}"
fi

# Check if emulator is already running
echo -e "\n${YELLOW}📱 Checking for Android emulator...${NC}"
if adb devices | grep -q "emulator-"; then
    echo -e "${GREEN}✓ Emulator is already running${NC}"
else
    echo -e "${YELLOW}Starting Android emulator (Medium_Phone_API_36.1)...${NC}"
    emulator -avd Medium_Phone_API_36.1 -no-snapshot-load > /dev/null 2>&1 &

    echo -e "${YELLOW}Waiting for emulator to boot...${NC}"
    adb wait-for-device

    # Wait for boot to complete
    echo -e "${YELLOW}Waiting for system to be ready...${NC}"
    while [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]; do
        sleep 2
    done

    echo -e "${GREEN}✓ Emulator is ready${NC}"
fi

# Configure ADB reverse port forwarding
echo -e "\n${YELLOW}🔗 Configuring port forwarding...${NC}"
adb reverse tcp:4000 tcp:4000
echo -e "${GREEN}✓ Port forwarding configured (emulator:4000 -> host:4000)${NC}"

# Verify port forwarding
adb reverse --list | grep "tcp:4000"

# Run Flutter app
echo -e "\n${YELLOW}🎯 Launching Flutter app...${NC}"
flutter run

echo -e "\n${GREEN}✅ Setup complete!${NC}"
