#!/usr/bin/env bash
set -euo pipefail

# rebuild-devcontainer.sh
# Usage: ./scripts/rebuild-devcontainer.sh [workspace-path]
# Tries to install the devcontainer CLI (using npm) if missing, then runs a rebuild.

WORKSPACE=${1:-$(pwd)}
cd "$WORKSPACE"

echo "Workspace: $WORKSPACE"

if command -v devcontainer >/dev/null 2>&1; then
  echo "devcontainer CLI already installed — rebuilding container..."
  # try multiple common invocations
  try_cmds=(
    "devcontainer rebuild --workspace-folder \"$WORKSPACE\""
    "devcontainer rebuild \"$WORKSPACE\""
    "devcontainer up --workspace-folder \"$WORKSPACE\" --rebuild"
    "devcontainers rebuild --workspace-folder \"$WORKSPACE\""
    "devcontainers up --workspace-folder \"$WORKSPACE\" --rebuild"
  )
  for c in "${try_cmds[@]}"; do
    echo "+ $c"
    if eval $c; then
      echo "Rebuild succeeded with: $c"
      exit 0
    else
      echo "Command failed: $c — trying next..."
    fi
  done
  echo "devcontainer CLI present but none of the recognized commands worked."
  exit 1
fi

if command -v npm >/dev/null 2>&1; then
  echo "Installing @devcontainers/cli via npm..."
  npm install -g @devcontainers/cli
  # after installing, try the invocations above
  if command -v devcontainer >/dev/null 2>&1; then
    echo "devcontainer installed — attempting rebuild variants..."
    try_cmds=(
      "devcontainer rebuild --workspace-folder \"$WORKSPACE\""
      "devcontainer rebuild \"$WORKSPACE\""
      "devcontainer up --workspace-folder \"$WORKSPACE\" --rebuild"
      "devcontainers rebuild --workspace-folder \"$WORKSPACE\""
      "devcontainers up --workspace-folder \"$WORKSPACE\" --rebuild"
    )
    for c in "${try_cmds[@]}"; do
      echo "+ $c"
      if eval $c; then
        echo "Rebuild succeeded with: $c"
        exit 0
      else
        echo "Command failed: $c — trying next..."
      fi
    done
  fi
  # fallback to npx remote runner
  echo "Falling back to npx @devcontainers/cli..."
  if command -v npx >/dev/null 2>&1; then
    if npx @devcontainers/cli@latest rebuild --workspace-folder "$WORKSPACE"; then
      exit 0
    fi
    if npx @devcontainers/cli@latest up --workspace-folder "$WORKSPACE" --rebuild; then
      exit 0
    fi
  fi
  echo "All attempts failed after npm install."
  exit 1
fi

# Determine package manager and install node/npm
PKG_CMD=""
if command -v apk >/dev/null 2>&1; then
  PKG_CMD="apk add --no-cache nodejs npm"
elif command -v apt-get >/dev/null 2>&1; then
  PKG_CMD="apt-get update && apt-get install -y nodejs npm"
elif command -v yum >/dev/null 2>&1; then
  PKG_CMD="yum install -y nodejs npm"
elif command -v dnf >/dev/null 2>&1; then
  PKG_CMD="dnf install -y nodejs npm"
else
  echo "No supported package manager found. Please install Node/npm or the devcontainer CLI manually."
  exit 1
fi

if command -v sudo >/dev/null 2>&1; then
  echo "Running: sudo $PKG_CMD"
  sudo sh -c "$PKG_CMD"
else
  echo "Running: $PKG_CMD (may require root privileges)"
  sh -c "$PKG_CMD"
fi

if command -v npm >/dev/null 2>&1; then
  echo "Installing @devcontainers/cli via npm..."
  npm install -g @devcontainers/cli
  # try variants after installing
  if command -v devcontainer >/dev/null 2>&1; then
    echo "devcontainer installed — attempting rebuild variants..."
    try_cmds=(
      "devcontainer rebuild --workspace-folder \"$WORKSPACE\""
      "devcontainer rebuild \"$WORKSPACE\""
      "devcontainer up --workspace-folder \"$WORKSPACE\" --rebuild"
      "devcontainers rebuild --workspace-folder \"$WORKSPACE\""
      "devcontainers up --workspace-folder \"$WORKSPACE\" --rebuild"
    )
    for c in "${try_cmds[@]}"; do
      echo "+ $c"
      if eval $c; then
        echo "Rebuild succeeded with: $c"
        exit 0
      else
        echo "Command failed: $c — trying next..."
      fi
    done
  fi
  # fallback to npx
  if command -v npx >/dev/null 2>&1; then
    if npx @devcontainers/cli@latest rebuild --workspace-folder "$WORKSPACE"; then
      exit 0
    fi
    if npx @devcontainers/cli@latest up --workspace-folder "$WORKSPACE" --rebuild; then
      exit 0
    fi
  fi
  echo "Failed to rebuild after installing devcontainer CLI."
  exit 1
fi

echo "Failed to install Node/npm or devcontainer CLI. Please install them manually and re-run this script."
exit 1
