from flask import Flask, render_template, request, redirect, url_for, flash, send_file, Response, stream_with_context

# Import with error handling
try:
    from pytubefix import YouTube
    YOUTUBE_AVAILABLE = True
except ImportError as e:
    print(f"⚠️  Warning: pytubefix not available: {e}")
    print("📥 Install with: pip install pytubefix")
    YOUTUBE_AVAILABLE = False
    YouTube = None

try:
    from facebook_video_downloader import FacebookVideoDownloader
    FACEBOOK_AVAILABLE = True
except ImportError as e:
    print(f"⚠️  Warning: facebook_video_downloader not available: {e}")
    FACEBOOK_AVAILABLE = False
    FacebookVideoDownloader = None

from config import Config
import os
import io
import tempfile
import logging
import json
import uuid
import subprocess

app = Flask(__name__)

# Load configuration
app.config.from_object(Config)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Facebook API configuration
FACEBOOK_API_URL = app.config['FACEBOOK_API_URL']

# Global variable to store progress (in a real app, you'd use a proper session or database)
progress_data = {}

# Progress callback function
def on_progress(stream, chunk, bytes_remaining):
    """Callback function to track download progress"""
    total_size = stream.filesize
    bytes_downloaded = total_size - bytes_remaining
    percentage = (bytes_downloaded / total_size) * 100
    
    # Store progress data globally (for demonstration purposes)
    progress_data['percentage'] = int(percentage)
    progress_data['downloaded'] = bytes_downloaded
    progress_data['total'] = total_size
    
    logger.info(f"Download progress: {int(percentage)}%")

@app.route('/')
def index():
    return render_template('index.html')
# ...existing code...

@app.route('/fetch', methods=['POST'])
def fetch_video():
    if not YOUTUBE_AVAILABLE:
        flash('YouTube downloader is not available. Please install pytubefix: pip install pytubefix')
        return redirect(url_for('index'))

    link = request.form.get('link')

    if not link:
        flash('Please enter a YouTube video link')
        return redirect(url_for('index'))

    try:
        youtube_video = YouTube(link)
        video_title = youtube_video.title
        video_views = youtube_video.views
        video_author = youtube_video.author
        video_length = youtube_video.length  # in seconds
        
        # Get all video streams (progressive and adaptive)
        video_streams = youtube_video.streams.filter(file_extension='mp4', type='video').order_by('resolution').desc()
        # Get audio streams
        audio_streams = youtube_video.streams.filter(only_audio=True).order_by('abr').desc()
        # Create a list of available video resolutions with their itag identifiers
        available_streams = []
        for stream in video_streams:
            if stream.resolution and int(stream.resolution[:-1]) >= 144:
                available_streams.append({
                    'itag': stream.itag,
                    'resolution': stream.resolution,
                    'mime_type': stream.mime_type,
                    'filesize': stream.filesize,
                    'is_progressive': stream.is_progressive,
                    'type': 'video'
                })
        # Add audio streams to available options
        for stream in audio_streams:
            available_streams.append({
                'itag': stream.itag,
                'resolution': stream.abr,  # Audio bitrate
                'mime_type': stream.mime_type,
                'filesize': stream.filesize,
                'type': 'audio'
            })
        
        return render_template('download.html', 
                             video_title=video_title,
                             video_views=video_views,
                             video_author=video_author,
                             video_length=video_length,
                             streams=available_streams,
                             link=link,
                             thumbnail_url=youtube_video.thumbnail_url)
    
    except Exception as e:
        logger.error(f"Error fetching video: {str(e)}")
        flash(f'Error fetching video: {str(e)}')
        return redirect(url_for('index'))

@app.route('/download', methods=['POST'])
def download_video():
    if not YOUTUBE_AVAILABLE:
        flash('YouTube downloader is not available. Please install pytubefix: pip install pytubefix')
        return redirect(url_for('index'))

    link = request.form.get('link')
    itag = request.form.get('itag')

    if not link or not itag:
        flash('Invalid request')
        return redirect(url_for('index'))

    try:
        # Create YouTube object with progress callback
        youtube_video = YouTube(link, on_progress_callback=on_progress)
        video_stream = youtube_video.streams.get_by_itag(int(itag))
        if not video_stream:
            flash('Selected stream not found')
            return redirect(url_for('index'))
        temp_dir = tempfile.gettempdir()
        # If progressive (video+audio), download directly
        if video_stream.is_progressive:
            filename = video_stream.download(output_path=temp_dir)
        elif video_stream.type == 'video':
            # Adaptive video: download video and best audio, then merge
            video_file = video_stream.download(output_path=temp_dir)
            audio_stream = youtube_video.streams.filter(only_audio=True).order_by('abr').desc().first()
            audio_file = audio_stream.download(output_path=temp_dir)
            merged_file = os.path.join(temp_dir, f"merged_{os.path.basename(video_file)}")
            # Merge using ffmpeg
            import subprocess
            cmd = [
                'ffmpeg', '-y',
                '-i', video_file,
                '-i', audio_file,
                '-c:v', 'copy',
                '-c:a', 'aac',
                '-strict', 'experimental',
                merged_file
            ]
            try:
                subprocess.run(cmd, check=True)
                filename = merged_file
            except Exception as e:
                logger.error(f"ffmpeg merge failed: {e}")
                flash(f'Failed to merge video and audio. Error: {e}')
                return redirect(url_for('index'))
        elif video_stream.type == 'audio':
            # Rename to .mp3 extension
            filename = video_stream.download(output_path=temp_dir)
            base_name = os.path.splitext(filename)[0]
            new_filename = base_name + '.mp3'
            os.rename(filename, new_filename)
            filename = new_filename
        else:
            flash('Unknown stream type')
            return redirect(url_for('index'))
        # Serve the file for download
        return send_file(filename, as_attachment=True)
        
    except Exception as e:
        logger.error(f"Error downloading video: {str(e)}")
        flash(f'Error downloading video: {str(e)}')
        return redirect(url_for('index'))

@app.route('/progress')
def get_progress():
    """Endpoint to get download progress"""
    return json.dumps(progress_data)

@app.route('/facebook')
def facebook_page():
    """Facebook downloader page"""
    return render_template('facebook.html')

@app.route('/facebook/download', methods=['POST'])
def download_facebook_video():
    """Download Facebook video"""
    if not FACEBOOK_AVAILABLE:
        flash('Facebook downloader is not available. Please check your installation.')
        return redirect(url_for('facebook_page'))

    facebook_url = request.form.get('facebook_url')

    if not facebook_url:
        flash('Please enter a Facebook video URL')
        return redirect(url_for('facebook_page'))

    try:
        # Initialize Facebook downloader
        downloader = FacebookVideoDownloader(FACEBOOK_API_URL)
        
        # Create temporary directory for downloads
        temp_dir = tempfile.gettempdir()
        downloads_folder = os.path.join(temp_dir, 'facebook_downloads')
        os.makedirs(downloads_folder, exist_ok=True)
        
        # Update downloader's download folder
        downloader.download_folder = downloads_folder
        
        # Fetch video data
        video_data = downloader.fetch_video_data(facebook_url)
        
        if not video_data:
            flash('Could not fetch video data. Please check the URL.')
            return redirect(url_for('facebook_page'))
        
        hd_url = video_data.get('hd')
        if not hd_url:
            flash('HD video URL not found.')
            return redirect(url_for('facebook_page'))
        
        video_title = video_data.get('title', 'facebook_video')
        
        # Sanitize filename
        def sanitize_title(title):
            return "".join([c for c in title if c.isalpha() or c.isdigit() or c in (' ', '-', '_')]).rstrip()
        
        safe_title = sanitize_title(video_title) + '.mp4'
        output_path = os.path.join(downloads_folder, safe_title)
        
        # Download the video
        import requests
        response = requests.get(hd_url, headers=downloader.get_headers(), stream=True)
        response.raise_for_status()
        
        with open(output_path, 'wb') as file:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    file.write(chunk)
        
        # Serve the file for download
        return send_file(output_path, as_attachment=True, download_name=safe_title)
        
    except Exception as e:
        logger.error(f"Error downloading Facebook video: {str(e)}")
        flash(f'Error downloading Facebook video: {str(e)}')
        return redirect(url_for('facebook_page'))

@app.route('/about')
def about():
    """About page route"""
    return render_template('about.html')

@app.route('/help')
def help():
    """Help page route"""
    return render_template('help.html')

@app.route('/credits')
def credits():
    """Credits and acknowledgments page"""
    return render_template('credits.html')

@app.route('/privacy')
def privacy():
    """Privacy policy page"""
    return render_template('privacy.html')

@app.route('/terms')
def terms():
    """Terms of service page"""
    return render_template('terms.html')

@app.route('/contact')
def contact():
    """Contact page"""
    return render_template('contact.html')

@app.route('/feedback')
def feedback():
    """Feedback page"""
    return render_template('feedback.html')

@app.route('/instagram')
def instagram_page():
    """Instagram downloader page"""
    return render_template('instagram.html')

@app.route('/instagram/download', methods=['POST'])
def download_instagram_reel():
    """Download Instagram reel"""
    instagram_url = request.form.get('instagram_url')
    
    if not instagram_url:
        flash('Please enter an Instagram reel URL')
        return redirect(url_for('instagram_page'))
    
    try:
        import instaloader
        from urllib.parse import urlparse
        import glob
        
        # Create temporary directory for downloads
        temp_dir = tempfile.gettempdir()
        download_dir = os.path.join(temp_dir, 'instagram_downloads')
        os.makedirs(download_dir, exist_ok=True)
        
        # Initialize Instaloader with specific settings
        L = instaloader.Instaloader(
            dirname_pattern=download_dir,
            filename_pattern='{shortcode}',
            save_metadata=False,
            download_video_thumbnails=False,
            download_pictures=False,
            download_geotags=False,
            download_comments=False,
            compress_json=False
        )
        
        # Extract shortcode from link
        path = urlparse(instagram_url).path
        parts = [p for p in path.split('/') if p]
        
        # Handle different Instagram URL formats
        shortcode = None
        if 'reel' in parts:
            shortcode_index = parts.index('reel') + 1
            if shortcode_index < len(parts):
                shortcode = parts[shortcode_index]
        elif 'p' in parts:
            shortcode_index = parts.index('p') + 1
            if shortcode_index < len(parts):
                shortcode = parts[shortcode_index]
        
        # Try to extract shortcode from end of URL if not found
        if not shortcode and parts:
            shortcode = parts[-1]
        
        # Clean shortcode (remove query parameters)
        if shortcode and '?' in shortcode:
            shortcode = shortcode.split('?')[0]
            
        if not shortcode:
            flash('Invalid Instagram URL. Please check the link and try again.')
            return redirect(url_for('instagram_page'))
        
        logger.info(f"Attempting to download Instagram content with shortcode: {shortcode}")
        
        try:
            # Get post information first
            post = instaloader.Post.from_shortcode(L.context, shortcode)
            
            # Check if post contains video
            if not post.is_video:
                flash('This Instagram post does not contain a video. Only video posts and reels can be downloaded.')
                return redirect(url_for('instagram_page'))
            
            logger.info(f"Post found: {post.caption[:50] if post.caption else 'No caption'}...")
            logger.info(f"Is video: {post.is_video}, Video duration: {post.video_duration if post.is_video else 'N/A'}")
            
            # Download the post
            L.download_post(post, target='')
            
            # Look for downloaded video files with multiple patterns
            possible_patterns = [
                os.path.join(download_dir, f"{shortcode}.mp4"),
                os.path.join(download_dir, f"*{shortcode}*.mp4"),
                os.path.join(download_dir, f"{shortcode}_*.mp4"),
            ]
            
            video_file = None
            for pattern in possible_patterns:
                files = glob.glob(pattern)
                if files:
                    video_file = files[0]
                    break
            
            # If still not found, look for any mp4 files in the download directory
            if not video_file:
                mp4_files = glob.glob(os.path.join(download_dir, "*.mp4"))
                # Sort by modification time, get the newest
                if mp4_files:
                    video_file = max(mp4_files, key=os.path.getmtime)
            
            if not video_file or not os.path.exists(video_file):
                # List all files in download directory for debugging
                all_files = os.listdir(download_dir)
                logger.error(f"Video file not found. Files in download directory: {all_files}")
                flash('Download completed but video file not found. The content might be protected or unavailable.')
                return redirect(url_for('instagram_page'))
            
            # Generate a clean filename
            clean_filename = f"instagram_reel_{shortcode}.mp4"
            
            logger.info(f"Successfully found video file: {video_file}")
            
            return send_file(video_file, as_attachment=True, download_name=clean_filename)
            
        except instaloader.exceptions.ProfileNotExistsException:
            flash('Instagram profile not found. Please check the URL.')
            return redirect(url_for('instagram_page'))
        except instaloader.exceptions.PostChangedException:
            flash('This Instagram post is no longer available.')
            return redirect(url_for('instagram_page'))
        except instaloader.exceptions.LoginRequiredException:
            flash('This Instagram content requires login. Only public content can be downloaded.')
            return redirect(url_for('instagram_page'))
        except instaloader.exceptions.PrivateProfileNotFollowedException:
            flash('This Instagram profile is private. Only public content can be downloaded.')
            return redirect(url_for('instagram_page'))
        except instaloader.exceptions.InstaloaderException as e:
            logger.error(f"Instaloader error: {str(e)}")
            flash(f'Instagram download error: {str(e)}')
            return redirect(url_for('instagram_page'))
        except Exception as e:
            logger.error(f"Unexpected error during Instagram download: {str(e)}")
            flash(f'Failed to download Instagram content: {str(e)}')
            return redirect(url_for('instagram_page'))
            
    except ImportError:
        flash('Instagram downloader not available. Please install required dependencies.')
        return redirect(url_for('instagram_page'))
    except Exception as e:
        logger.error(f"Error downloading Instagram content: {str(e)}")
        flash(f'Error downloading Instagram content: {str(e)}')
        return redirect(url_for('instagram_page'))

if __name__ == '__main__':
    import socket
    
    def is_port_available(port):
        """Check if a port is available"""
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            try:
                s.bind(('0.0.0.0', port))
                return True
            except socket.error:
                return False
    
    # Get configuration values
    PORT = app.config.get('PORT', 5000)
    HOST = app.config.get('HOST', '0.0.0.0')
    DEBUG = app.config.get('DEBUG', True)
    
    # Ensure port is available
    if not is_port_available(PORT):
        print(f"⚠️  Port {PORT} is already in use!")
        print("Please close any other applications using this port or choose a different port.")
        print("Common solutions:")
        print("1. Close any other Flask/Django servers")
        print("2. Close VS Code terminals running servers")
        print("3. Restart VS Code")
        print("4. Check Task Manager for python.exe processes")
        
        # Try to find an alternative port
        for alternative_port in range(PORT + 1, PORT + 10):
            if is_port_available(alternative_port):
                PORT = alternative_port
                print(f"✅ Using alternative port: {PORT}")
                break
        else:
            print("❌ No available ports found in range. Please manually close other servers.")
            exit(1)
    
    print("🚀 Starting Video Downloader Pro...")
    print(f"📺 YouTube Downloader: http://localhost:{PORT}")
    print(f"📘 Facebook Downloader: http://localhost:{PORT}/facebook")
    print(f"📱 Instagram Downloader: http://localhost:{PORT}/instagram")
    print(f"🌐 Network Access: http://0.0.0.0:{PORT}")
    print(f"🌍 External Access: http://<your-ip-address>:{PORT}")
    print("Press Ctrl+C to stop the server")
    
    try:
        app.run(
            debug=DEBUG, 
            host=HOST, 
            port=PORT, 
            use_reloader=False,  # Disable reloader to prevent port conflicts
            threaded=True
        )
    except OSError as e:
        if "Address already in use" in str(e):
            print(f"❌ Error: Port {PORT} is still in use.")
            print("Solution: Close other applications or restart your computer.")
        else:
            print(f"❌ Server error: {e}")
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user.")
