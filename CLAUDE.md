# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a showroom template repo with "localroom" -- a local dev environment for showroom content authors. It provides a split-pane browser UI with lab content on the left and tabbed terminal/editor on the right, replicating the deployed showroom experience locally.

## Architecture

- **localroom.sh** -- single entry-point script that builds Antora content, starts ttyd + code-server, and serves a Split.js-based split-pane UI
- Uses `ghcr.io/juliaaano/antora-viewer` image with entrypoint override for builds (bundles mermaid extension)
- Auto-detects `site.yml` or `antora-playbook.yml`
- Split-pane UI uses [Split.js](https://split.js.org/) (same library as upstream showroom at `redhat-cop/agnosticd`)
- Antora content in standard showroom layout: `content/modules/ROOT/pages/`

## Key Commands

```bash
./localroom.sh start    # Build + start all services
./localroom.sh stop     # Stop all services
./localroom.sh build    # Rebuild Antora content only
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
