#!/bin/sh
# Post-create script for devcontainer
# This runs after the container is created to install additional dependencies

set -e

echo "Installing additional MkDocs plugins and tools..."

# Install additional plugins from requirements.txt
pip install --upgrade pip
pip install -r requirements.txt

echo "Verifying installation..."
mkdocs --version
python -c "import mkdocs_ezlinks_plugin; print('ezlinks plugin installed')" || echo "Warning: ezlinks plugin not found"
python -c "import mkpatcher; print('mkpatcher extension installed')" || echo "Warning: mkpatcher extension not found"

echo "✅ DevContainer setup complete!"
echo ""
echo "To build the documentation:"
echo "  mkdocs build"
echo ""
echo "To serve locally (with live reload):"
echo "  mkdocs serve --dev-addr=0.0.0.0:8000"
echo ""
echo "To check for broken links:"
echo "  ./scripts/check-links.sh"

