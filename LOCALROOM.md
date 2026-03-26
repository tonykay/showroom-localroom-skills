# Localroom - Local Showroom Dev Environment

A single-script local dev environment for showroom content authors. Builds your Antora content and serves it in a split-pane browser UI alongside a terminal and code editor -- just like the deployed showroom experience.

## How It Works

`localroom.sh` lives inside your showroom repo and orchestrates three services:

1. **Build** -- Runs the Antora container to generate static HTML from `site.yml` (or `antora-playbook.yml`)
2. **ttyd** -- Browser-based terminal (zsh) on port 9001
3. **code-server** -- VS Code in the browser on port 9002, opened to this repo
4. **Lab server** -- Python HTTP server on port 8080 serves a split-pane page:
   - **Left panel**: Your built Antora lab content (from `./www/`)
   - **Right panel**: Tabbed iframes -- Terminal (default) and Code Editor
   - Draggable split divider via Split.js

## Prerequisites

| Tool | Install | Purpose |
|------|---------|---------|
| **ttyd** | `brew install ttyd` | Browser-based terminal |
| **code-server** | `brew install code-server` | VS Code in the browser |
| **zsh** | Pre-installed on macOS | Shell for ttyd |
| **Podman** or **Docker** | `brew install podman` | Runs the Antora build container |
| **Python 3** | Pre-installed on macOS | Serves the combined UI |

## Usage

From your showroom repo root:

```bash
# Start everything (build + services + UI)
./localroom.sh start

# Stop all services
./localroom.sh stop

# Rebuild Antora content only
./localroom.sh build
```

Then open http://localhost:8080 in your browser.

## Ports

| Service | Default Port | Override |
|---------|-------------|----------|
| Lab UI | 8080 | `LAB_PORT=8888` |
| Terminal (ttyd) | 9001 | `TTYD_PORT=9011` |
| Code Editor | 9002 | `CODE_SERVER_PORT=9012` |

Example with custom ports:

```bash
LAB_PORT=3000 TTYD_PORT=3001 CODE_SERVER_PORT=3002 ./localroom.sh start
```

## Antora Build

The script auto-detects `site.yml` or `antora-playbook.yml`. Output goes to `./www/` (gitignored). Override the playbook filename:

```bash
ANTORA_PLAYBOOK=custom-site.yml ./localroom.sh start
```

The default image (`ghcr.io/juliaaano/antora-viewer`) bundles the mermaid extension used by showroom repos. Override with:

```bash
ANTORA_IMAGE=docker.io/antora/antora ./localroom.sh start
```

## Adding Localroom to Your Showroom Repo

Copy `localroom.sh` and `LOCALROOM.md` into your showroom repo root. Add to `.gitignore`:

```
.localroom-ui.html
.pids/
```

## Stopping Services

`Ctrl+C` during `./localroom.sh start` stops everything cleanly. Or from another terminal: `./localroom.sh stop`
