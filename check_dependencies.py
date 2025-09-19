#!/usr/bin/env python3

"""
FetchFlicks Dependency Checker
This script checks if all required dependencies are properly installed
"""

import sys
import subprocess
import importlib.util

def check_python_version():
    """Check if Python version is compatible"""
    version = sys.version_info
    print(f"🐍 Python version: {version.major}.{version.minor}.{version.micro}")
    
    if version.major >= 3 and version.minor >= 6:
        print("✅ Python version is compatible")
        return True
    else:
        print("❌ Python 3.6+ is required")
        return False

def check_package(package_name, import_name=None):
    """Check if a Python package is installed"""
    if import_name is None:
        import_name = package_name
    
    try:
        spec = importlib.util.find_spec(import_name)
        if spec is not None:
            print(f"✅ {package_name}: Available")
            return True
        else:
            print(f"❌ {package_name}: Not found")
            return False
    except ImportError:
        print(f"❌ {package_name}: Import error")
        return False

def check_system_command(command):
    """Check if a system command is available"""
    try:
        result = subprocess.run([command, '--version'], 
                              capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            version = result.stdout.strip().split('\n')[0]
            print(f"✅ {command}: {version}")
            return True
        else:
            print(f"❌ {command}: Not working properly")
            return False
    except (subprocess.TimeoutExpired, FileNotFoundError, subprocess.CalledProcessError):
        print(f"❌ {command}: Not found")
        return False

def main():
    print("=" * 50)
    print("🔍 FetchFlicks Dependency Checker")
    print("=" * 50)
    print()
    
    all_good = True
    
    # Check Python version
    print("1. Python Version:")
    if not check_python_version():
        all_good = False
    print()
    
    # Check Python packages
    print("2. Python Packages:")
    required_packages = [
        ('flask', 'flask'),
        ('pytubefix', 'pytubefix'),
        ('instaloader', 'instaloader'),
        ('requests', 'requests'),
        ('tqdm', 'tqdm'),
        ('gunicorn', 'gunicorn')
    ]
    
    for package_name, import_name in required_packages:
        if not check_package(package_name, import_name):
            all_good = False
    print()
    
    # Check system commands
    print("3. System Commands:")
    system_commands = ['node', 'npm', 'ffmpeg', 'git']
    
    for command in system_commands:
        if not check_system_command(command):
            if command in ['node', 'npm']:
                print(f"   ⚠️  {command} is optional for Next.js component")
            elif command == 'ffmpeg':
                print(f"   ⚠️  {command} is required for video merging")
                all_good = False
            else:
                print(f"   ⚠️  {command} is optional")
    print()
    
    # Check virtual environment
    print("4. Virtual Environment:")
    if hasattr(sys, 'real_prefix') or (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix):
        print("✅ Running in virtual environment")
    else:
        print("⚠️  Not running in virtual environment")
        print("   Recommendation: Use virtual environment for better isolation")
    print()
    
    # Summary
    print("=" * 50)
    if all_good:
        print("🎉 All essential dependencies are available!")
        print("You can start the application with: python3 yt_downloader_app.py")
    else:
        print("❌ Some dependencies are missing!")
        print()
        print("Quick fixes:")
        print("1. Install missing Python packages:")
        print("   pip install flask pytubefix instaloader requests tqdm gunicorn")
        print()
        print("2. Install system dependencies (Ubuntu):")
        print("   sudo apt install ffmpeg nodejs npm")
        print()
        print("3. Run the fix script:")
        print("   ./fix_ubuntu_issues.sh")
    print("=" * 50)

if __name__ == "__main__":
    main()
