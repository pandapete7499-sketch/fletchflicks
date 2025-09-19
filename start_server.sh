#!/bin/bash

# FetchFlicks Video Downloader - Ubuntu/Linux Startup Script
# This script starts the main Flask server for YouTube, Facebook, and Instagram downloading

echo "=============================================="
echo "   🎬 FetchFlicks Video Downloader Pro"
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

# Check if Python3 is installed
if ! command_exists python3; then
    echo -e "${RED}❌ Python3 is not installed!${NC}"
    echo "Please install Python3:"
    echo "sudo apt update && sudo apt install python3 python3-pip"
    exit 1
fi

echo -e "${GREEN}✅ Python3 found: $(python3 --version)${NC}"

# Check if pip is installed
if ! command_exists pip3; then
    echo -e "${YELLOW}⚠️  pip3 not found, installing...${NC}"
    sudo apt install python3-pip -y
fi

# Check if virtual environment exists
if [ -d ".venv" ]; then
    echo -e "${GREEN}✅ Virtual environment found${NC}"
    source .venv/bin/activate
    PYTHON_CMD=".venv/bin/python"
elif [ -d "venv" ]; then
    echo -e "${GREEN}✅ Virtual environment found${NC}"
    source venv/bin/activate
    PYTHON_CMD="venv/bin/python"
else
    echo -e "${YELLOW}⚠️  No virtual environment found, creating one...${NC}"
    python3 -m venv .venv
    source .venv/bin/activate
    PYTHON_CMD=".venv/bin/python"
    echo -e "${GREEN}✅ Virtual environment created${NC}"
fi

# Install/upgrade requirements
echo -e "${BLUE}📦 Installing/updating dependencies...${NC}"
pip install --upgrade pip
pip install -r requirements.txt

# Check if ffmpeg is installed (needed for video merging)
if ! command_exists ffmpeg; then
    echo -e "${YELLOW}⚠️  ffmpeg not found. Installing...${NC}"
    echo "This is required for merging video and audio streams."
    sudo apt update
    sudo apt install ffmpeg -y
    if command_exists ffmpeg; then
        echo -e "${GREEN}✅ ffmpeg installed successfully${NC}"
    else
        echo -e "${RED}❌ Failed to install ffmpeg. Some features may not work.${NC}"
    fi
else
    echo -e "${GREEN}✅ ffmpeg found${NC}"
fi

# Check if port 5000 is available
if ! is_port_available 5000; then
    echo -e "${RED}❌ Port 5000 is already in use!${NC}"
    echo "Please stop any other services using port 5000 or:"
    echo "1. Kill the process: sudo lsof -ti:5000 | xargs kill -9"
    echo "2. Or use a different port by modifying config.py"
    exit 1
fi

echo ""
echo -e "${GREEN}🚀 Starting FetchFlicks Video Downloader...${NC}"
echo ""
echo "Available services:"
echo "📺 YouTube Downloader: http://localhost:5000"
echo "📘 Facebook Downloader: http://localhost:5000/facebook"
echo "📱 Instagram Downloader: http://localhost:5000/instagram"
echo ""
echo "🌐 Network access: http://0.0.0.0:5000"
echo "🌍 External access: http://$(hostname -I | awk '{print $1}'):5000"
echo ""
echo "Press Ctrl+C to stop the server"
echo "=============================================="

# Start the Flask application
$PYTHON_CMD yt_downloader_app.py
