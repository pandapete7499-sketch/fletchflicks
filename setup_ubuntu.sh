#!/bin/bash

# FetchFlicks Video Downloader - Ubuntu Setup Script
# This script sets up the environment for running FetchFlicks on Ubuntu

echo "=============================================="
echo "   🎬 FetchFlicks Ubuntu Setup Script"
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

echo -e "${BLUE}📦 Updating package list...${NC}"
sudo apt update

# Install Python3 and pip if not already installed
if ! command_exists python3; then
    echo -e "${YELLOW}📥 Installing Python3...${NC}"
    sudo apt install python3 -y
else
    echo -e "${GREEN}✅ Python3 already installed: $(python3 --version)${NC}"
fi

if ! command_exists pip3; then
    echo -e "${YELLOW}📥 Installing pip3...${NC}"
    sudo apt install python3-pip -y
else
    echo -e "${GREEN}✅ pip3 already installed${NC}"
fi

# Install python3-venv for virtual environments
echo -e "${YELLOW}📥 Installing python3-venv...${NC}"
sudo apt install python3-venv -y

# Install Node.js and npm (for Next.js Instagram downloader)
if ! command_exists node; then
    echo -e "${YELLOW}📥 Installing Node.js and npm...${NC}"
    # Try multiple installation methods
    if command_exists curl; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt install nodejs -y
    else
        # Fallback to Ubuntu repository
        sudo apt install nodejs npm -y
    fi

    # Verify installation
    if command_exists node; then
        echo -e "${GREEN}✅ Node.js installed: $(node --version)${NC}"
    else
        echo -e "${RED}❌ Node.js installation failed${NC}"
        echo -e "${YELLOW}⚠️  Next.js component will not be available${NC}"
    fi
else
    echo -e "${GREEN}✅ Node.js already installed: $(node --version)${NC}"
fi

# Install npm if not present
if ! command_exists npm; then
    echo -e "${YELLOW}📥 Installing npm...${NC}"
    sudo apt install npm -y
fi

# Install ffmpeg (required for video processing)
if ! command_exists ffmpeg; then
    echo -e "${YELLOW}📥 Installing ffmpeg...${NC}"
    sudo apt install ffmpeg -y
else
    echo -e "${GREEN}✅ ffmpeg already installed${NC}"
fi

# Install additional system dependencies
echo -e "${YELLOW}📥 Installing additional system dependencies...${NC}"
sudo apt install -y \
    curl \
    wget \
    git \
    build-essential \
    netcat

# Create virtual environment
if [ ! -d ".venv" ]; then
    echo -e "${YELLOW}🔧 Creating virtual environment...${NC}"
    python3 -m venv .venv
    echo -e "${GREEN}✅ Virtual environment created${NC}"
else
    echo -e "${GREEN}✅ Virtual environment already exists${NC}"
fi

# Activate virtual environment and install Python dependencies
echo -e "${YELLOW}📦 Installing Python dependencies...${NC}"
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Install Next.js dependencies if the directory exists
if [ -d "Instagram-reels-downloader" ]; then
    echo -e "${YELLOW}📦 Installing Next.js dependencies...${NC}"
    cd Instagram-reels-downloader
    npm install
    cd ..
    echo -e "${GREEN}✅ Next.js dependencies installed${NC}"
else
    echo -e "${BLUE}ℹ️  Next.js Instagram downloader directory not found (optional)${NC}"
fi

# Make startup scripts executable
chmod +x start_server.sh
if [ -f "start_servers.py" ]; then
    chmod +x start_servers.py
fi

echo ""
echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
echo ""
echo "To start the application:"
echo "1. Run: ./start_server.sh"
echo "2. Or run: python3 start_servers.py"
echo "3. Or run: python3 yt_downloader_app.py"
echo ""
echo "The application will be available at:"
echo "📺 http://localhost:5000 (YouTube, Facebook, Instagram)"
echo "🌐 http://0.0.0.0:5000 (Network access)"
echo ""
echo "If you have the Next.js component:"
echo "🔗 http://localhost:3000 (Advanced Instagram downloader)"
echo ""
echo "=============================================="
