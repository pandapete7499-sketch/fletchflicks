# 🚀 FetchFlicks Ubuntu Quick Start Guide

## 🆘 **EMERGENCY FIX** - If you're having issues right now:

```bash
# 1. Navigate to your project directory
cd /home/rushabh/downloader/fletchflicks/

# 2. Run the emergency fix script
./fix_ubuntu_issues.sh

# 3. Start the application
./start_server.sh
```

## 📋 **Step-by-Step Solution for Your Specific Issues:**

### Issue 1: `ModuleNotFoundError: no module named instaloader`

**Problem**: System Python is being used instead of virtual environment

**Solution**:
```bash
# Remove corrupted virtual environment
rm -rf .venv

# Create fresh virtual environment
python3 -m venv .venv

# Activate it (IMPORTANT!)
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Verify installation
python3 check_dependencies.py
```

### Issue 2: `sh: 1: next: not found`

**Problem**: Next.js is not properly installed or not in PATH

**Solution**:
```bash
# Install Node.js and npm
sudo apt update
sudo apt install nodejs npm -y

# Install Next.js globally
sudo npm install -g next

# Fix the Next.js project
cd Instagram-reels-downloader
rm -rf node_modules package-lock.json
npm install
cd ..
```

### Issue 3: Server Auto-Shutdown

**Problem**: Servers crash due to import errors

**Solution**: The updated code now has error handling that prevents crashes

## 🔧 **Complete Fix Process:**

### Option 1: Automated Fix (Recommended)
```bash
cd /home/rushabh/downloader/fletchflicks/
./fix_ubuntu_issues.sh
```

### Option 2: Manual Fix
```bash
# 1. Install system dependencies
sudo apt update
sudo apt install python3 python3-pip python3-venv python3-dev build-essential ffmpeg nodejs npm -y

# 2. Create fresh virtual environment
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate

# 3. Install Python packages
pip install --upgrade pip
pip install flask==2.3.3 pytubefix>=6.0.0 instaloader==4.12 requests==2.31.0 tqdm==4.66.1 gunicorn==21.2.0

# 4. Fix Next.js (optional)
sudo npm install -g next
cd Instagram-reels-downloader
npm install
cd ..

# 5. Make scripts executable
chmod +x *.sh *.py

# 6. Test dependencies
python3 check_dependencies.py
```

## 🚀 **Starting the Application:**

### Method 1: Using the startup script
```bash
./start_server.sh
```

### Method 2: Using Python directly
```bash
source .venv/bin/activate
python3 yt_downloader_app.py
```

### Method 3: Using the multi-server script
```bash
python3 start_servers.py
```

## 🌐 **Accessing the Application:**

Once started, access at:
- **Local**: http://localhost:5000
- **Network**: http://0.0.0.0:5000
- **External**: http://YOUR_IP_ADDRESS:5000

Services available:
- 📺 **YouTube**: http://localhost:5000
- 📘 **Facebook**: http://localhost:5000/facebook
- 📱 **Instagram**: http://localhost:5000/instagram

## 🔍 **Troubleshooting Commands:**

```bash
# Check all dependencies
python3 check_dependencies.py

# Run comprehensive diagnostics
./troubleshoot_ubuntu.sh

# Check if virtual environment is active
which python3

# Check installed packages
pip list

# Check if ports are available
netstat -tlnp | grep :5000

# Kill processes on port 5000
sudo lsof -ti:5000 | xargs kill -9
```

## 🛠 **Common Issues and Quick Fixes:**

### Virtual Environment Not Activating
```bash
# Make sure you're in the right directory
cd /home/rushabh/downloader/fletchflicks/

# Activate virtual environment
source .venv/bin/activate

# Verify it's active (should show .venv path)
which python3
```

### Permission Denied Errors
```bash
chmod +x *.sh *.py
```

### Port Already in Use
```bash
sudo lsof -ti:5000 | xargs kill -9
```

### Missing System Dependencies
```bash
sudo apt install python3-dev build-essential ffmpeg nodejs npm -y
```

## 📞 **Still Having Issues?**

1. **Check the console output** for specific error messages
2. **Run the dependency checker**: `python3 check_dependencies.py`
3. **Run the troubleshooter**: `./troubleshoot_ubuntu.sh`
4. **Make sure you're in the right directory**: `/home/rushabh/downloader/fletchflicks/`
5. **Ensure virtual environment is activated**: `source .venv/bin/activate`

## ✅ **Success Indicators:**

You'll know it's working when you see:
```
🚀 Starting Video Downloader Pro...
📺 YouTube downloader: http://localhost:5000
📘 Facebook downloader: http://localhost:5000/facebook
📱 Instagram downloader: http://localhost:5000/instagram
🌐 Network Access: http://0.0.0.0:5000
```

## 🔒 **Security Note:**

The application binds to `0.0.0.0:5000` for network access. If you want local-only access, change the `HOST` setting in `config.py` to `127.0.0.1`.
