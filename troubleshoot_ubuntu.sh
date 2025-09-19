#!/bin/bash

# FetchFlicks Video Downloader - Ubuntu Troubleshooting Script
# This script helps diagnose and fix common issues on Ubuntu

echo "=============================================="
echo "   🔧 FetchFlicks Troubleshooting Tool"
echo "=============================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a port is available
is_port_available() {
    ! nc -z localhost $1 2>/dev/null
}

echo -e "${BLUE}🔍 Running system diagnostics...${NC}"
echo ""

# Check Python installation
echo "1. Python Installation:"
if command_exists python3; then
    echo -e "   ${GREEN}✅ Python3: $(python3 --version)${NC}"
else
    echo -e "   ${RED}❌ Python3 not found${NC}"
    echo "   Fix: sudo apt update && sudo apt install python3"
fi

if command_exists pip3; then
    echo -e "   ${GREEN}✅ pip3 installed${NC}"
else
    echo -e "   ${RED}❌ pip3 not found${NC}"
    echo "   Fix: sudo apt install python3-pip"
fi

echo ""

# Check Node.js installation
echo "2. Node.js Installation:"
if command_exists node; then
    echo -e "   ${GREEN}✅ Node.js: $(node --version)${NC}"
else
    echo -e "   ${YELLOW}⚠️  Node.js not found (optional for Next.js component)${NC}"
fi

if command_exists npm; then
    echo -e "   ${GREEN}✅ npm: $(npm --version)${NC}"
else
    echo -e "   ${YELLOW}⚠️  npm not found (optional for Next.js component)${NC}"
fi

echo ""

# Check ffmpeg installation
echo "3. ffmpeg Installation:"
if command_exists ffmpeg; then
    echo -e "   ${GREEN}✅ ffmpeg installed${NC}"
else
    echo -e "   ${RED}❌ ffmpeg not found${NC}"
    echo "   Fix: sudo apt install ffmpeg"
fi

echo ""

# Check virtual environment
echo "4. Virtual Environment:"
if [ -d ".venv" ]; then
    echo -e "   ${GREEN}✅ .venv directory exists${NC}"
    if [ -f ".venv/bin/python" ]; then
        echo -e "   ${GREEN}✅ Python executable in venv${NC}"
    else
        echo -e "   ${RED}❌ Python executable missing in venv${NC}"
        echo "   Fix: rm -rf .venv && python3 -m venv .venv"
    fi
elif [ -d "venv" ]; then
    echo -e "   ${GREEN}✅ venv directory exists${NC}"
else
    echo -e "   ${YELLOW}⚠️  No virtual environment found${NC}"
    echo "   Fix: python3 -m venv .venv"
fi

echo ""

# Check port availability
echo "5. Port Availability:"
if is_port_available 5000; then
    echo -e "   ${GREEN}✅ Port 5000 is available${NC}"
else
    echo -e "   ${RED}❌ Port 5000 is in use${NC}"
    echo "   Processes using port 5000:"
    lsof -ti:5000 2>/dev/null | while read pid; do
        echo "     PID: $pid - $(ps -p $pid -o comm=)"
    done
    echo "   Fix: sudo lsof -ti:5000 | xargs kill -9"
fi

if is_port_available 3000; then
    echo -e "   ${GREEN}✅ Port 3000 is available${NC}"
else
    echo -e "   ${YELLOW}⚠️  Port 3000 is in use (for Next.js)${NC}"
fi

echo ""

# Check required files
echo "6. Required Files:"
required_files=("yt_downloader_app.py" "config.py" "requirements.txt" "start_servers.py")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "   ${GREEN}✅ $file exists${NC}"
    else
        echo -e "   ${RED}❌ $file missing${NC}"
    fi
done

echo ""

# Check Python dependencies
echo "7. Python Dependencies:"
if [ -f "requirements.txt" ]; then
    echo -e "   ${BLUE}📦 Checking Python packages...${NC}"
    
    # Activate virtual environment if it exists
    if [ -d ".venv" ]; then
        source .venv/bin/activate
    elif [ -d "venv" ]; then
        source venv/bin/activate
    fi
    
    # Check each requirement
    while IFS= read -r requirement; do
        if [[ ! "$requirement" =~ ^[[:space:]]*# ]] && [[ -n "$requirement" ]]; then
            package=$(echo "$requirement" | cut -d'=' -f1 | cut -d'>' -f1 | cut -d'<' -f1)
            if python3 -c "import $package" 2>/dev/null; then
                echo -e "   ${GREEN}✅ $package${NC}"
            else
                echo -e "   ${RED}❌ $package${NC}"
            fi
        fi
    done < requirements.txt
else
    echo -e "   ${RED}❌ requirements.txt not found${NC}"
fi

echo ""
echo "=============================================="
echo -e "${BLUE}🔧 Quick Fixes:${NC}"
echo ""
echo "1. Install missing dependencies:"
echo "   ./setup_ubuntu.sh"
echo ""
echo "2. Recreate virtual environment:"
echo "   rm -rf .venv && python3 -m venv .venv"
echo "   source .venv/bin/activate"
echo "   pip install -r requirements.txt"
echo ""
echo "3. Kill processes on port 5000:"
echo "   sudo lsof -ti:5000 | xargs kill -9"
echo ""
echo "4. Start the application:"
echo "   ./start_server.sh"
echo ""
echo "5. Check firewall (if accessing from another machine):"
echo "   sudo ufw allow 5000"
echo "   sudo ufw allow 3000"
echo ""
echo "=============================================="
