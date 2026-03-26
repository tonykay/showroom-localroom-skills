#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
LAB_PORT="${LAB_PORT:-8080}"
TTYD_PORT="${TTYD_PORT:-9001}"
CODE_SERVER_PORT="${CODE_SERVER_PORT:-9002}"
ANTORA_IMAGE="${ANTORA_IMAGE:-ghcr.io/juliaaano/antora-viewer}"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
ANTORA_PLAYBOOK="${ANTORA_PLAYBOOK:-site.yml}"
WWW_DIR="${REPO_DIR}/www"
PID_DIR="${REPO_DIR}/.pids"
GENERATED_HTML="${REPO_DIR}/.homeroom-ui.html"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[homeroom]${NC} $*"; }
warn()  { echo -e "${YELLOW}[homeroom]${NC} $*"; }
error() { echo -e "${RED}[homeroom]${NC} $*" >&2; }

# --- Prerequisite checks ---
check_prereqs() {
    local missing=()
    command -v ttyd       >/dev/null 2>&1 || missing+=(ttyd)
    command -v code-server >/dev/null 2>&1 || missing+=(code-server)
    command -v zsh        >/dev/null 2>&1 || missing+=(zsh)

    # Need either podman or docker for Antora builds
    if ! command -v podman >/dev/null 2>&1 && ! command -v docker >/dev/null 2>&1; then
        missing+=("podman or docker")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing prerequisites: ${missing[*]}"
        error "See HOMEROOM.md for installation instructions."
        exit 1
    fi
}

# --- Container runtime ---
container_cmd() {
    if command -v podman >/dev/null 2>&1; then
        echo podman
    else
        echo docker
    fi
}

# --- Build Antora content ---
build_content() {
    # Look for site.yml (showroom convention) or antora-playbook.yml
    local playbook=""
    if [[ -f "${REPO_DIR}/${ANTORA_PLAYBOOK}" ]]; then
        playbook="${ANTORA_PLAYBOOK}"
    elif [[ -f "${REPO_DIR}/antora-playbook.yml" ]]; then
        playbook="antora-playbook.yml"
    elif [[ -f "${REPO_DIR}/site.yml" ]]; then
        playbook="site.yml"
    fi

    if [[ -z "${playbook}" ]]; then
        warn "No Antora playbook found -- skipping build."
        warn "Add a site.yml or antora-playbook.yml to this repo."
        mkdir -p "${WWW_DIR}"
        if [[ ! -f "${WWW_DIR}/index.html" ]]; then
            cat > "${WWW_DIR}/index.html" <<'PLACEHOLDER'
<!DOCTYPE html>
<html><head><title>Homeroom</title>
<style>body{font-family:system-ui;padding:2rem;color:#333}
h1{color:#2c5282}code{background:#edf2f7;padding:0.2em 0.4em;border-radius:3px}</style>
</head><body>
<h1>Homeroom</h1>
<p>No Antora content built yet. Add a <code>site.yml</code> or <code>antora-playbook.yml</code> to this repo.</p>
</body></html>
PLACEHOLDER
        fi
        return
    fi

    info "Building Antora content (${playbook})..."
    local runtime
    runtime=$(container_cmd)
    ${runtime} run --rm --entrypoint antora -v "${REPO_DIR}:/antora:Z" "${ANTORA_IMAGE}" "${playbook}"
    info "Antora build complete -> ${WWW_DIR}"
}

# --- Generate the split-pane UI ---
generate_ui() {
    cat > "${GENERATED_HTML}" <<'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Home School Lab</title>
<style>
  * { box-sizing: border-box; height: 100%; }
  body { margin: 0; height: 100%; }

  .content {
    width: 100%;
    height: 100%;
    padding: 0;
    display: flex;
    justify-items: center;
    align-items: center;
    margin-top: 0;
  }

  .split { width: 100%; height: 100%; }
  .left { height: 100%; }
  .right { height: 100%; display: flex; flex-direction: column; }

  /* Split.js gutter styling */
  .gutter {
    height: 98%;
    background-color: #eee;
    background-repeat: no-repeat;
    background-position: 50%;
  }
  .gutter.gutter-horizontal {
    background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAeCAYAAADkftS9AAAAIklEQVQoU2M4c+bMfxAGAgYYmwGrIIiDjrELjpo5aiZeMwF+yNnOs5KSvgAAAABJRU5ErkJggg==');
    cursor: col-resize;
  }

  /* Tab bar */
  .tab {
    overflow: hidden;
    border: 1px solid #ccc;
    background-color: #f1f1f1;
    height: 50px;
    display: flex;
    flex-direction: row;
    flex-shrink: 0;
  }
  .tab button {
    background-color: inherit;
    float: left;
    border: none;
    outline: none;
    cursor: pointer;
    padding: 14px 16px;
    transition: 0.3s;
    height: auto;
  }
  .tab button:hover { background-color: #ddd; }
  .tab button.active { background-color: #ccc; }

  /* Tab content */
  .tabcontent {
    display: none;
    padding: 0;
    border: 1px solid #ccc;
    border-top: none;
    height: calc(100% - 50px);
  }

  #terminal_tab { background: #000; }

  iframe { width: 100%; height: 100%; border: none; }
</style>
</head>
<body>
  <div class="content">
    <div class="split left">
      <iframe id="doc" src="/lab/" title="Lab Content"></iframe>
    </div>
    <div class="split right">
      <div class="tab">
        <button class="tablinks active" onclick="openTab(event, 'terminal_tab')" id="defaultOpen">Terminal</button>
        <button class="tablinks" onclick="openTab(event, 'editor_tab')">Code Editor</button>
      </div>
      <div id="terminal_tab" class="tabcontent" style="display:block;">
        <iframe src="TTYD_URL_PLACEHOLDER" title="Terminal"></iframe>
      </div>
      <div id="editor_tab" class="tabcontent">
        <iframe src="CODE_SERVER_URL_PLACEHOLDER" title="Code Editor"></iframe>
      </div>
    </div>
  </div>

  <script>
    function openTab(evt, tabName) {
      var i, tabcontent, tablinks;
      tabcontent = document.getElementsByClassName("tabcontent");
      for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = "none";
      }
      tablinks = document.getElementsByClassName("tablinks");
      for (i = 0; i < tablinks.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(" active", "");
      }
      document.getElementById(tabName).style.display = "block";
      evt.currentTarget.className += " active";
    }
  </script>
  <script src="https://unpkg.com/split.js/dist/split.min.js"></script>
  <script>
    Split(['.left', '.right'], {
      sizes: [45, 55],
    });
  </script>
</body>
</html>
HTMLEOF

    # Replace placeholder URLs with actual ports
    sed -i '' \
        -e "s|TTYD_URL_PLACEHOLDER|http://localhost:${TTYD_PORT}|g" \
        -e "s|CODE_SERVER_URL_PLACEHOLDER|http://localhost:${CODE_SERVER_PORT}|g" \
        "${GENERATED_HTML}"
}

# --- Start services ---
start_services() {
    mkdir -p "${PID_DIR}"

    # Start ttyd
    info "Starting ttyd on port ${TTYD_PORT}..."
    ttyd -W -p "${TTYD_PORT}" zsh &
    echo $! > "${PID_DIR}/ttyd.pid"

    # Start code-server (disable auth for local use)
    info "Starting code-server on port ${CODE_SERVER_PORT}..."
    code-server --bind-addr "127.0.0.1:${CODE_SERVER_PORT}" --auth none --disable-telemetry "${REPO_DIR}" &
    echo $! > "${PID_DIR}/code-server.pid"

    # Brief pause for services to bind
    sleep 1
}

# --- Serve the combined UI ---
start_server() {
    generate_ui

    # Use Python's built-in HTTP server with custom routing
    info "Starting lab server on port ${LAB_PORT}..."
    info "  Lab UI:        http://localhost:${LAB_PORT}"
    info "  Terminal:      http://localhost:${TTYD_PORT}"
    info "  Code Editor:   http://localhost:${CODE_SERVER_PORT}"
    echo ""
    info "Press Ctrl+C to stop all services."

    # Create a small Python server that serves the split UI at / and lab content at /lab/
    python3 -c "
import http.server
import os
import sys
import mimetypes
import urllib.parse

GENERATED_HTML = '${GENERATED_HTML}'
WWW_DIR = '${WWW_DIR}'

class LabHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # Strip query string for file resolution
        parsed = urllib.parse.urlparse(self.path)
        clean_path = urllib.parse.unquote(parsed.path)

        if clean_path == '/' or clean_path == '/index.html':
            self.send_response(200)
            self.send_header('Content-Type', 'text/html')
            self.end_headers()
            with open(GENERATED_HTML, 'rb') as f:
                self.wfile.write(f.read())
        elif clean_path.startswith('/lab'):
            # Serve Antora content from www/
            rel_path = clean_path[4:]  # strip /lab
            if rel_path.startswith('/'):
                rel_path = rel_path[1:]
            if not rel_path:
                rel_path = 'index.html'
            file_path = os.path.join(WWW_DIR, rel_path)
            if os.path.isdir(file_path):
                file_path = os.path.join(file_path, 'index.html')
            if os.path.isfile(file_path):
                self.send_response(200)
                ctype = mimetypes.guess_type(file_path)[0] or 'application/octet-stream'
                self.send_header('Content-Type', ctype)
                self.end_headers()
                with open(file_path, 'rb') as f:
                    self.wfile.write(f.read())
            else:
                self.send_error(404, 'File not found: ' + clean_path)
        else:
            # Try serving from www/ root as well (for Antora assets like _/ paths)
            rel_path = clean_path.lstrip('/')
            file_path = os.path.join(WWW_DIR, rel_path)
            if os.path.isfile(file_path):
                self.send_response(200)
                ctype = mimetypes.guess_type(file_path)[0] or 'application/octet-stream'
                self.send_header('Content-Type', ctype)
                self.end_headers()
                with open(file_path, 'rb') as f:
                    self.wfile.write(f.read())
            else:
                self.send_error(404)

    def log_message(self, format, *args):
        pass  # Suppress request logs

server = http.server.HTTPServer(('127.0.0.1', ${LAB_PORT}), LabHandler)
print(f'Lab server running on http://localhost:${LAB_PORT}', flush=True)
server.serve_forever()
" &
    echo $! > "${PID_DIR}/server.pid"

    # Wait for interrupt
    trap 'stop_services; exit 0' INT TERM
    wait
}

# --- Stop services ---
stop_services() {
    info "Stopping services..."
    if [[ -d "${PID_DIR}" ]]; then
        for pidfile in "${PID_DIR}"/*.pid; do
            [[ -f "${pidfile}" ]] || continue
            local pid
            pid=$(cat "${pidfile}")
            if kill -0 "${pid}" 2>/dev/null; then
                kill "${pid}" 2>/dev/null || true
                info "  Stopped PID ${pid} ($(basename "${pidfile}" .pid))"
            fi
            rm -f "${pidfile}"
        done
        rmdir "${PID_DIR}" 2>/dev/null || true
    fi
    rm -f "${GENERATED_HTML}"
    info "All services stopped."
}

# --- Main ---
usage() {
    echo "Usage: $0 {start|stop|build}"
    echo ""
    echo "  start   Build content (if needed), start all services, and open the lab"
    echo "  stop    Stop all running services"
    echo "  build   Build Antora content only"
    echo ""
    echo "Environment variables:"
    echo "  ANTORA_PLAYBOOK   Playbook filename (default: site.yml)"
    echo "  LAB_PORT          Main UI port (default: 8080)"
    echo "  TTYD_PORT         Terminal port (default: 9001)"
    echo "  CODE_SERVER_PORT  Code editor port (default: 9002)"
    echo "  ANTORA_IMAGE      Antora container image"
}

case "${1:-}" in
    start)
        check_prereqs
        build_content
        start_services
        start_server
        ;;
    stop)
        stop_services
        ;;
    build)
        build_content
        ;;
    *)
        usage
        exit 1
        ;;
esac
