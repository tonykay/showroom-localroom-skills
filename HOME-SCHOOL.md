# Home School Lab Environment

A single-script lab environment that combines Antora documentation with an interactive terminal (ttyd) and code editor (code-server) in a split-pane browser interface.

## How It Works

`home-school.sh` orchestrates three services behind a single browser page:

1. **Build** -- Runs the Antora container (`ghcr.io/juliaaano/antora-viewer` by default) to generate static HTML from the content source repo. Auto-detects `site.yml` or `antora-playbook.yml`.
2. **ttyd** -- Starts a browser-based terminal (zsh) on port 9001
3. **code-server** -- Starts VS Code in the browser on port 9002, opened to the content source directory
4. **Lab server** -- A Python HTTP server on port 8080 serves a split-pane page:
   - **Left panel**: Antora lab content (from `<content-source>/www/`)
   - **Right panel**: Tabbed iframes -- Terminal (default) and Code Editor
   - The divider between panels is draggable

## Prerequisites

| Tool | Install | Purpose |
|------|---------|---------|
| **ttyd** | `brew install ttyd` | Browser-based terminal |
| **code-server** | `brew install code-server` | VS Code in the browser |
| **zsh** | Pre-installed on macOS | Shell for ttyd |
| **Podman** or **Docker** | `brew install podman` | Runs the Antora build container |
| **Python 3** | Pre-installed on macOS | Serves the combined UI |

## Usage

```bash
# Start everything (build + services + UI)
./home-school.sh start

# Stop all services
./home-school.sh stop

# Rebuild Antora content only
./home-school.sh build
```

Then open http://localhost:8080 in your browser.

## Content Source

By default, the script looks for content in `./showroom_sample/` (a clone of `rhpds/showroom_template_nookbag`). Point to any showroom or Antora repo:

```bash
CONTENT_SOURCE=/path/to/my-showroom ./home-school.sh start
```

The script auto-detects the playbook (`site.yml` or `antora-playbook.yml`). Override with `ANTORA_PLAYBOOK=custom.yml`.

## Ports

| Service | Default Port | Override |
|---------|-------------|----------|
| Lab UI | 8080 | `LAB_PORT=8888` |
| Terminal (ttyd) | 9001 | `TTYD_PORT=9011` |
| Code Editor | 9002 | `CODE_SERVER_PORT=9012` |

Example with custom ports:

```bash
LAB_PORT=3000 TTYD_PORT=3001 CODE_SERVER_PORT=3002 ./home-school.sh start
```

## Antora Content

Place your `antora-playbook.yml` in the project root. The build step runs:

```
podman run --rm -v .:/antora:Z ghcr.io/juliaaano/antora antora-playbook.yml
```

Output goes to `./www/`. If no playbook is found, a placeholder page is served instead.

Override the Antora image with:

```bash
ANTORA_IMAGE=docker.io/antora/antora ./home-school.sh start
```

Note: The default image (`ghcr.io/juliaaano/antora-viewer`) bundles the mermaid extension used by showroom repos. The base `antora/antora` image won't work if the playbook uses extensions.

## File Layout

```
home-school/
  home-school.sh          # Main entry script
  HOME-SCHOOL.md          # This file
  CLAUDE.md               # Claude Code guidance
  showroom_sample/        # Sample showroom content (cloned from rhpds/showroom_template_nookbag)
    site.yml              # Antora playbook
    content/              # Antora modules
    www/                  # Built output (generated)
  .pids/                  # PID files for running services (transient)
  .home-school-ui.html    # Generated split-pane page (transient)
```

## Stopping Services

`Ctrl+C` during `./home-school.sh start` stops everything cleanly. You can also run `./home-school.sh stop` from another terminal.
