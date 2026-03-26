# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Home-school is a self-contained lab environment that serves Antora-built documentation alongside interactive tools (terminal via ttyd, code editor via code-server) in a split-pane iframe interface. The target use case is guided hands-on labs where learners read instructions on the left and work in a terminal/editor on the right.

## Architecture

- **home-school.sh** -- single entry-point script that builds Antora content, starts ttyd and code-server, and serves the combined iframe page
- **showroom_sample/** -- cloned showroom template repo used as test content (from `rhpds/showroom_template_nookbag`)
- Content source is configurable via `CONTENT_SOURCE` env var (defaults to `./showroom_sample`)
- Uses `ghcr.io/juliaaano/antora-viewer` image with entrypoint override for builds (bundles mermaid extension)
- The script auto-detects `site.yml` or `antora-playbook.yml` in the content source
- Split-pane UI uses [Split.js](https://split.js.org/) (same library as the upstream showroom at `redhat-cop/agnosticd`)

## Key Commands

```bash
# Full startup (build + serve)
./home-school.sh start

# Stop all services
./home-school.sh stop

# Rebuild Antora content only
./home-school.sh build

# Use a different showroom repo
CONTENT_SOURCE=/path/to/showroom ./home-school.sh start
```

## Service Ports (defaults)

| Service       | Port |
|---------------|------|
| Lab UI        | 8080 |
| ttyd terminal | 9001 |
| code-server   | 9002 |

## Prerequisites

- ttyd (`brew install ttyd` on macOS)
- code-server (`brew install code-server` or `npm install -g code-server`)
- Podman or Docker (for Antora builds)
- zsh

## Conventions

- Always use Pydantic V2 for structured outputs with OpenAI API
- Bash is the preferred scripting language for tooling in this project
- Showroom content follows standard Antora module layout (`content/modules/ROOT/pages/`)
