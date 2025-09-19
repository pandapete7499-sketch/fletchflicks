# FetchFlicks Video Downloader - Ubuntu/Linux Setup Guide

🎬 **FetchFlicks** is a comprehensive video downloader that supports YouTube, Facebook, and Instagram content.

## 🚀 Quick Start for Ubuntu/Linux

### Option 1: Automated Setup (Recommended)

```bash
# 1. Clone or download the project
git clone https://github.com/pandapete7499-sketch/fletchflicks.git
cd fletchflicks

# 2. Run the setup script
./setup_ubuntu.sh

# 3. Start the application
./start_server.sh
```

### Option 2: Manual Setup

```bash
# 1. Install system dependencies
sudo apt update
sudo apt install python3 python3-pip python3-venv ffmpeg nodejs npm -y

# 2. Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# 3. Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt

# 4. Install Next.js dependencies (optional)
cd Instagram-reels-downloader
npm install
cd ..

# 5. Start the application
python3 yt_downloader_app.py
```

## 🌐 Accessing the Application

Once started, the application will be available at:

- **Main Application**: http://localhost:5000
  - 📺 YouTube Downloader: http://localhost:5000
  - 📘 Facebook Downloader: http://localhost:5000/facebook
  - 📱 Instagram Downloader: http://localhost:5000/instagram

- **Network Access**: http://0.0.0.0:5000
- **External Access**: http://YOUR_IP_ADDRESS:5000

- **Next.js Component** (if available): http://localhost:3000

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. "Unable to connect" or "Connection refused"

**Cause**: Server not binding properly or firewall blocking connections.

**Solutions**:
```bash
# Check if the server is running
ps aux | grep python

# Check if ports are open
netstat -tlnp | grep :5000

# Allow ports through firewall
sudo ufw allow 5000
sudo ufw allow 3000

# Check server logs
./start_server.sh
```

#### 2. "Port already in use"

**Cause**: Another process is using port 5000.

**Solutions**:
```bash
# Find and kill processes using port 5000
sudo lsof -ti:5000 | xargs kill -9

# Or use the troubleshooting script
./troubleshoot_ubuntu.sh
```

#### 3. "Module not found" errors

**Cause**: Missing Python dependencies.

**Solutions**:
```bash
# Activate virtual environment
source .venv/bin/activate

# Reinstall dependencies
pip install -r requirements.txt

# Or run setup again
./setup_ubuntu.sh
```

#### 4. "ffmpeg not found"

**Cause**: ffmpeg is required for video processing.

**Solution**:
```bash
sudo apt install ffmpeg -y
```

#### 5. Virtual environment issues

**Cause**: Corrupted or missing virtual environment.

**Solution**:
```bash
# Remove and recreate virtual environment
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 🔍 Diagnostic Tools

Run the troubleshooting script to automatically diagnose issues:

```bash
./troubleshoot_ubuntu.sh
```

This script will check:
- Python and pip installation
- Node.js and npm (for Next.js component)
- ffmpeg installation
- Virtual environment status
- Port availability
- Required files
- Python dependencies

## 🌍 Network Access

To access the application from other devices on your network:

1. **Find your IP address**:
   ```bash
   hostname -I
   ```

2. **Allow ports through firewall**:
   ```bash
   sudo ufw allow 5000
   sudo ufw allow 3000
   ```

3. **Access from other devices**:
   - Use: http://YOUR_IP_ADDRESS:5000

## 📱 Features

- **YouTube Downloader**: Download videos in various qualities
- **Facebook Video Downloader**: Download Facebook videos
- **Instagram Downloader**: Download Instagram reels and videos
- **Multiple Formats**: Support for MP4, MP3, and various resolutions
- **Progress Tracking**: Real-time download progress
- **Network Access**: Access from any device on your network

## 🛠 Development

### Running in Development Mode

```bash
# Activate virtual environment
source .venv/bin/activate

# Run with debug mode
python3 yt_downloader_app.py

# Or run all servers
python3 start_servers.py
```

### File Structure

```
fetchflicks/
├── yt_downloader_app.py      # Main Flask application
├── start_servers.py          # Multi-server startup script
├── config.py                 # Configuration settings
├── requirements.txt          # Python dependencies
├── start_server.sh           # Ubuntu startup script
├── setup_ubuntu.sh           # Ubuntu setup script
├── troubleshoot_ubuntu.sh    # Troubleshooting script
├── templates/                # HTML templates
├── static/                   # CSS, JS, images
└── Instagram-reels-downloader/ # Next.js component (optional)
```

## 📞 Support

If you encounter issues:

1. Run the troubleshooting script: `./troubleshoot_ubuntu.sh`
2. Check the console output for error messages
3. Ensure all dependencies are installed
4. Verify firewall settings for network access

## 🔒 Security Notes

- The application binds to `0.0.0.0:5000` for network access
- Only use on trusted networks
- Consider using a reverse proxy (nginx) for production deployments
- Keep dependencies updated for security

## 📄 License

This project is open source. Please respect the terms of service of the platforms you're downloading from.
