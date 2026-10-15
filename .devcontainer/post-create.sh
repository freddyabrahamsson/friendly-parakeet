#!/usr/bin/env bash

set -euo pipefail

uv python install 3.14
uv tool install --python 3.14 mistral-vibe
uv tool install --python 3.14 linode-cli

chmod +x .devcontainer/install-opentofu.sh
./.devcontainer/install-opentofu.sh --install-method standalone