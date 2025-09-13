#!/usr/bin/env python3
"""
Motorbike Sharing System Dashboard
Web-based dashboard for monitoring and controlling the orchestrated services
"""

import os
import json
import subprocess
import threading
import time
from datetime import datetime
from flask import Flask, render_template_string, jsonify, request
import webbrowser
from pathlib import Path

app = Flask(__name__)

# Configuration
BE_PORT = 8081  # Default, may be 8080 in fallback mode
FE_PORT = 3000
LOG_DIR = "logs"
BE_REPO = "https://github.com/FPTU-Capstone-Project/MotorbikeSharingSystem_BE.git"
FE_REPO = "https://github.com/FPTU-Capstone-Project/MotorbikeSharingSystem_FE.git"

def run_command(command):
    """Execute shell command and return result"""
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        return {
            'success': result.returncode == 0,
            'output': result.stdout,
            'error': result.stderr
        }
    except Exception as e:
        return {
            'success': False,
            'output': '',
            'error': str(e)
        }

def check_service_status():
    """Check if services are running"""
    # Smart detect backend port (8081 Docker mode or 8080 fallback mode)
    backend_port = BE_PORT
    be_status = run_command(f"lsof -Pi :{BE_PORT} -sTCP:LISTEN -t")
    
    # If 8081 not found, try 8080 (fallback mode)
    if not (be_status['success'] and bool(be_status['output'].strip())):
        fallback_port = 8080
        be_fallback_status = run_command(f"lsof -Pi :{fallback_port} -sTCP:LISTEN -t")
        if be_fallback_status['success'] and bool(be_fallback_status['output'].strip()):
            backend_port = fallback_port
            be_status = be_fallback_status
    
    fe_status = run_command(f"lsof -Pi :{FE_PORT} -sTCP:LISTEN -t")
    
    return {
        'backend': {
            'running': be_status['success'] and bool(be_status['output'].strip()),
            'port': backend_port,
            'url': f'http://localhost:{backend_port}',
            'swagger_url': f'http://localhost:{backend_port}/swagger-ui.html'
        },
        'frontend': {
            'running': fe_status['success'] and bool(fe_status['output'].strip()),
            'port': FE_PORT,
            'url': f'http://localhost:{FE_PORT}'
        }
    }

def get_latest_commits():
    """Get latest commit info from repositories"""
    commits = {}
    
    for repo_name, repo_dir in [('backend', 'backend'), ('frontend', 'frontend')]:
        if os.path.exists(repo_dir):
            try:
                # Get latest commit info
                cmd = f"cd {repo_dir} && git log -1 --format='%H|%an|%ad|%s' --date=iso"
                result = run_command(cmd)
                
                if result['success'] and result['output'].strip():
                    parts = result['output'].strip().split('|')
                    commits[repo_name] = {
                        'hash': parts[0][:8],
                        'author': parts[1],
                        'date': parts[2],
                        'message': parts[3]
                    }
                
                # Check for updates (only if git fetch works)
                fetch_result = run_command(f"cd {repo_dir} && git fetch origin 2>/dev/null || echo 'fetch_failed'")
                if 'fetch_failed' not in fetch_result['output']:
                    status_result = run_command(f"cd {repo_dir} && git status -uno")
                    commits[repo_name]['needs_update'] = 'behind' in status_result['output']
                else:
                    commits[repo_name]['needs_update'] = False
                
            except Exception as e:
                commits[repo_name] = {'error': str(e)}
        else:
            # Repository not cloned yet
            commits[repo_name] = {
                'hash': 'N/A',
                'author': 'N/A',
                'date': 'Repository not cloned',
                'message': 'Run orchestrator to clone repositories',
                'needs_update': False
            }
    
    return commits

def get_logs(service, lines=50):
    """Get recent logs for a service"""
    log_files = {
        'backend-build': f'{LOG_DIR}/backend-build.log',
        'backend-runtime': f'{LOG_DIR}/backend-runtime.log',
        'frontend-install': f'{LOG_DIR}/frontend-install.log',
        'frontend-runtime': f'{LOG_DIR}/frontend-runtime.log',
        'orchestrator': f'{LOG_DIR}/orchestrator.log'
    }
    
    log_file = log_files.get(service)
    if not log_file or not os.path.exists(log_file):
        return []
    
    try:
        result = run_command(f"tail -n {lines} '{log_file}'")
        if result['success']:
            return result['output'].split('\n')
    except:
        pass
    
    return []

# Dashboard HTML template
DASHBOARD_HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Motorbike Sharing System - Dashboard</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333; min-height: 100vh; padding: 20px;
        }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { 
            background: white; border-radius: 10px; padding: 20px; 
            margin-bottom: 20px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .header h1 { color: #4CAF50; margin-bottom: 10px; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 20px; }
        .card { 
            background: white; border-radius: 10px; padding: 20px; 
            box-shadow: 0 4px 6px rgba(0,0,0,0.1); transition: transform 0.2s;
        }
        .card:hover { transform: translateY(-2px); }
        .status-indicator { 
            display: inline-block; width: 12px; height: 12px; 
            border-radius: 50%; margin-right: 8px;
        }
        .status-running { background: #4CAF50; }
        .status-stopped { background: #f44336; }
        .btn { 
            background: #2196F3; color: white; border: none; 
            padding: 10px 20px; border-radius: 5px; cursor: pointer; 
            margin: 5px; transition: background 0.2s;
        }
        .btn:hover { background: #1976D2; }
        .btn-danger { background: #f44336; }
        .btn-danger:hover { background: #d32f2f; }
        .btn-success { background: #4CAF50; }
        .btn-success:hover { background: #388E3C; }
        .swagger-link { 
            background: #FF9800; color: white; text-decoration: none; 
            padding: 4px 8px; border-radius: 3px; font-size: 12px;
            margin-left: 8px; display: inline-block;
        }
        .swagger-link:hover { background: #F57C00; color: white; }
        .logs { 
            background: #1e1e1e; color: #f0f0f0; padding: 15px; 
            border-radius: 5px; max-height: 300px; overflow-y: auto;
            font-family: 'Courier New', monospace; font-size: 12px;
        }
        .commit-info { 
            background: #f5f5f5; padding: 10px; border-radius: 5px; 
            margin: 10px 0; font-size: 14px;
        }
        .update-badge { 
            background: #ff9800; color: white; padding: 2px 8px; 
            border-radius: 12px; font-size: 12px; margin-left: 10px;
        }
        .controls { text-align: center; margin: 20px 0; }
        .loading { display: none; color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🏍️ Motorbike Sharing System Dashboard</h1>
            <p>Monitor and control your full-stack application</p>
            <div class="controls">
                <button class="btn btn-success" onclick="startServices()">🚀 Start All</button>
                <button class="btn btn-danger" onclick="stopServices()">🛑 Stop All</button>
                <button class="btn" onclick="refreshStatus()">🔄 Refresh</button>
                <button class="btn" onclick="pullUpdates()">⬇️ Pull Updates</button>
            </div>
            <div class="loading" id="loading">⏳ Processing...</div>
        </div>

        <div class="stats">
            <div class="card">
                <h3>Service Status</h3>
                <div id="service-status">Loading...</div>
            </div>
            
            <div class="card">
                <h3>Quick Actions</h3>
                <div>
                    <button class="btn" onclick="openService('frontend')">📱 Open Frontend</button>
                    <button class="btn" onclick="openService('backend')">⚙️ Open Backend</button>
                    <button class="btn" onclick="showLogs('orchestrator')">📋 View Logs</button>
                </div>
            </div>
        </div>

        <div class="stats">
            <div class="card">
                <h3>Latest Changes</h3>
                <div id="commit-info">Loading commits...</div>
            </div>
        </div>

        <div class="card">
            <h3>Live Logs</h3>
            <div>
                <button class="btn" onclick="showLogs('orchestrator')">Orchestrator</button>
                <button class="btn" onclick="showLogs('backend-runtime')">Backend</button>
                <button class="btn" onclick="showLogs('frontend-runtime')">Frontend</button>
            </div>
            <div id="logs" class="logs">Select a log source above</div>
        </div>
    </div>

    <script>
        let autoRefresh = true;
        
        async function makeRequest(endpoint, method = 'GET', body = null) {
            document.getElementById('loading').style.display = 'inline';
            try {
                const response = await fetch(endpoint, {
                    method,
                    headers: { 'Content-Type': 'application/json' },
                    body: body ? JSON.stringify(body) : null
                });
                return await response.json();
            } finally {
                document.getElementById('loading').style.display = 'none';
            }
        }
        
        async function refreshStatus() {
            const status = await makeRequest('/api/status');
            
            let html = '';
            for (const [service, info] of Object.entries(status.services)) {
                const indicator = info.running ? 'status-running' : 'status-stopped';
                const statusText = info.running ? 'Running' : 'Stopped';
                let links = '';
                if (info.running) {
                    links += `<a href="${info.url}" target="_blank" title="Open ${service}">🔗</a>`;
                    if (service === 'backend' && info.swagger_url) {
                        links += ` <a href="${info.swagger_url}" target="_blank" class="swagger-link" title="API Documentation">📖 Swagger</a>`;
                    }
                }
                html += `
                    <div style="margin: 10px 0;">
                        <span class="status-indicator ${indicator}"></span>
                        <strong>${service.charAt(0).toUpperCase() + service.slice(1)}:</strong> 
                        ${statusText} (Port ${info.port})
                        ${links}
                    </div>
                `;
            }
            
            document.getElementById('service-status').innerHTML = html;
        }
        
        async function refreshCommits() {
            const commits = await makeRequest('/api/commits');
            
            let html = '';
            for (const [repo, info] of Object.entries(commits)) {
                if (info.error) {
                    html += `<div class="commit-info">❌ ${repo}: ${info.error}</div>`;
                } else {
                    html += `
                        <div class="commit-info">
                            <strong>📁 ${repo.toUpperCase()}</strong>
                            ${info.needs_update ? '<span class="update-badge">Update Available</span>' : ''}
                            <br>
                            <small>
                                ${info.hash} • ${info.author} • ${new Date(info.date).toLocaleString()}
                                <br>${info.message}
                            </small>
                        </div>
                    `;
                }
            }
            
            document.getElementById('commit-info').innerHTML = html || 'No repository information available';
        }
        
        async function startServices() {
            await makeRequest('/api/start', 'POST');
            setTimeout(refreshStatus, 2000);
        }
        
        async function stopServices() {
            await makeRequest('/api/stop', 'POST');
            setTimeout(refreshStatus, 1000);
        }
        
        async function pullUpdates() {
            await makeRequest('/api/pull', 'POST');
            setTimeout(() => {
                refreshCommits();
                refreshStatus();
            }, 3000);
        }
        
        async function showLogs(service) {
            const logs = await makeRequest(`/api/logs/${service}`);
            document.getElementById('logs').innerHTML = logs.logs.join('<br>') || 'No logs available';
        }
        
        function openService(service) {
            const urls = {
                frontend: `http://localhost:${3000}`,
                backend: `http://localhost:${8081}`
            };
            window.open(urls[service], '_blank');
        }
        
        // Auto-refresh every 10 seconds
        setInterval(() => {
            if (autoRefresh) {
                refreshStatus();
                refreshCommits();
            }
        }, 10000);
        
        // Initial load
        refreshStatus();
        refreshCommits();
    </script>
</body>
</html>
"""

# API Routes
@app.route('/')
def dashboard():
    return render_template_string(DASHBOARD_HTML)

@app.route('/api/status')
def api_status():
    return jsonify({
        'services': check_service_status(),
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/commits')
def api_commits():
    return jsonify(get_latest_commits())

@app.route('/api/logs/<service>')
def api_logs(service):
    return jsonify({
        'service': service,
        'logs': get_logs(service),
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/start', methods=['POST'])
def api_start():
    result = run_command('./orchestrator.sh start')
    return jsonify(result)

@app.route('/api/stop', methods=['POST'])
def api_stop():
    result = run_command('./orchestrator.sh stop')
    return jsonify(result)

@app.route('/api/pull', methods=['POST'])
def api_pull():
    # Pull updates for both repositories
    results = {}
    for repo_name, repo_dir in [('backend', 'backend'), ('frontend', 'frontend')]:
        if os.path.exists(repo_dir):
            result = run_command(f'cd {repo_dir} && git pull')
            results[repo_name] = result
    return jsonify(results)

def open_browser():
    """Open browser after server starts"""
    time.sleep(1.5)
    webbrowser.open('http://localhost:5001')

if __name__ == '__main__':
    print("🚀 Starting Motorbike Sharing System Dashboard...")
    print("📊 Dashboard will be available at: http://localhost:5001")
    
    # Create logs directory if it doesn't exist
    os.makedirs(LOG_DIR, exist_ok=True)
    
    # Open browser in a separate thread
    threading.Thread(target=open_browser).start()
    
    # Start Flask app
    app.run(host='0.0.0.0', port=5001, debug=False)