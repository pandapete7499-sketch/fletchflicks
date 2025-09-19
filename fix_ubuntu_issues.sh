#!/bin/bash

# FetchFlicks Ubuntu Issue Fixer
# This script specifically addresses the common Ubuntu issues

echo "=============================================="
echo "   🔧 FetchFlicks Ubuntu Issue Fixer"
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

echo -e "${BLUE}🔧 Fixing common Ubuntu issues...${NC}"
echo ""

# Issue 1: Fix Python virtual environment and dependencies
echo -e "${YELLOW}1. Fixing Python virtual environment issues...${NC}"

# Remove existing problematic virtual environment
if [ -d ".venv" ]; then
    echo "   Removing existing virtual environment..."
    rm -rf .venv
fi

# Create fresh virtual environment
echo "   Creating fresh virtual environment..."
python3 -m venv .venv

# Activate virtual environment
echo "   Activating virtual environment..."
source .venv/bin/activate

# Upgrade pip
echo "   Upgrading pip..."
pip install --upgrade pip

# Install Python dependencies one by one with error handling
echo "   Installing Python dependencies..."

packages=(
    "flask==2.3.3"
    "pytubefix>=6.0.0"
    "gunicorn==21.2.0"
    "instaloader==4.12"
    "requests==2.31.0"
    "tqdm==4.66.1"
)

for package in "${packages[@]}"; do
    echo "   Installing $package..."
    if pip install "$package"; then
        echo -e "   ${GREEN}✅ $package installed successfully${NC}"
    else
        echo -e "   ${RED}❌ Failed to install $package${NC}"
        # Try alternative installation
        echo "   Trying alternative installation..."
        pip install --no-cache-dir "$package" || echo -e "   ${RED}❌ Alternative installation also failed${NC}"
    fi
done

echo ""

# Issue 2: Fix Node.js and Next.js issues
echo -e "${YELLOW}2. Fixing Node.js and Next.js issues...${NC}"

# Install Node.js if not present
if ! command_exists node; then
    echo "   Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install nodejs -y
fi

# Install npm if not present
if ! command_exists npm; then
    echo "   Installing npm..."
    sudo apt install npm -y
fi

# Update npm to latest version
echo "   Updating npm..."
sudo npm install -g npm@latest

# Install Next.js globally
echo "   Installing Next.js globally..."
sudo npm install -g next

# Fix Next.js project if it exists
if [ -d "Instagram-reels-downloader" ]; then
    echo "   Fixing Next.js project..."
    cd Instagram-reels-downloader
    
    # Remove node_modules and package-lock.json
    rm -rf node_modules package-lock.json
    
    # Install dependencies
    npm install
    
    # Install Next.js locally if not in package.json
    if ! grep -q '"next"' package.json; then
        npm install next react react-dom
    fi
    
    cd ..
    echo -e "   ${GREEN}✅ Next.js project fixed${NC}"
else
    echo -e "   ${BLUE}ℹ️  Next.js project directory not found (optional)${NC}"
fi

echo ""

# Issue 3: Fix system dependencies
echo -e "${YELLOW}3. Installing missing system dependencies...${NC}"

# Update package list
sudo apt update

# Install essential packages
essential_packages=(
    "python3-dev"
    "python3-pip"
    "python3-venv"
    "build-essential"
    "ffmpeg"
    "curl"
    "wget"
    "git"
    "netcat"
)

for package in "${essential_packages[@]}"; do
    echo "   Installing $package..."
    sudo apt install -y "$package"
done

echo ""

# Issue 4: Fix permissions and make scripts executable
echo -e "${YELLOW}4. Fixing file permissions...${NC}"

chmod +x start_server.sh
chmod +x setup_ubuntu.sh
chmod +x troubleshoot_ubuntu.sh
chmod +x fix_ubuntu_issues.sh

echo -e "${GREEN}✅ File permissions fixed${NC}"

echo ""

# Issue 5: Test the installation
echo -e "${YELLOW}5. Testing the installation...${NC}"

# Activate virtual environment
source .venv/bin/activate

# Test Python imports
echo "   Testing Python imports..."
python3 -c "
try:
    import flask
    print('✅ Flask: OK')
except ImportError as e:
    print(f'❌ Flask: {e}')

try:
    import pytubefix
    print('✅ pytubefix: OK')
except ImportError as e:
    print(f'❌ pytubefix: {e}')

try:
    import instaloader
    print('✅ instaloader: OK')
except ImportError as e:
    print(f'❌ instaloader: {e}')

try:
    import requests
    print('✅ requests: OK')
except ImportError as e:
    print(f'❌ requests: {e}')
"

# Test Node.js
if command_exists node; then
    echo -e "   ${GREEN}✅ Node.js: $(node --version)${NC}"
else
    echo -e "   ${RED}❌ Node.js: Not found${NC}"
fi

if command_exists npm; then
    echo -e "   ${GREEN}✅ npm: $(npm --version)${NC}"
else
    echo -e "   ${RED}❌ npm: Not found${NC}"
fi

echo ""
echo "=============================================="
echo -e "${GREEN}🎉 Ubuntu issues fixed!${NC}"
echo ""
echo "Next steps:"
echo "1. Start the application: ./start_server.sh"
echo "2. Or run: python3 yt_downloader_app.py"
echo "3. Access at: http://localhost:5000"
echo ""
echo "If you still have issues:"
echo "1. Run: ./troubleshoot_ubuntu.sh"
echo "2. Check the console output for specific errors"
echo "3. Make sure you're in the project directory"
echo ""
echo "=============================================="
