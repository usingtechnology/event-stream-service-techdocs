#!/bin/bash
# Script to build documentation and check for broken links

set -e

echo "🔨 Building documentation..."
mkdocs build

echo ""
echo "🌐 Starting local server in background..."
mkdocs serve --dev-addr=0.0.0.0:8000 > /tmp/mkdocs-server.log 2>&1 &
SERVER_PID=$!

# Wait for server to start
sleep 3

# Check if server is running
if ! kill -0 $SERVER_PID 2>/dev/null; then
    echo "❌ Failed to start MkDocs server"
    cat /tmp/mkdocs-server.log
    exit 1
fi

echo "✅ Server started (PID: $SERVER_PID)"
echo ""
echo "🔍 Checking for broken links..."

# Use linkchecker if available, otherwise provide manual instructions
if command -v linkchecker &> /dev/null; then
    linkchecker http://localhost:8000 \
        --check-extern \
        --no-robots \
        --ignore-url="^mailto:" \
        --ignore-url="^https://teams.microsoft.com" \
        --ignore-url="^https://bcgov.sharepoint.com" \
        --ignore-url="^https://ess-fider.apps.silver.devops.gov.bc.ca" \
        --ignore-url="^https://chat.developer.gov.bc.ca" \
        --timeout=10 \
        --threads=5 || true
    
    echo ""
    echo "📋 Link check complete. Review the output above for any broken links."
else
    echo "⚠️  linkchecker not installed. Install it with: pip install linkchecker"
    echo ""
    echo "📋 Manual check:"
    echo "  1. Open http://localhost:8000 in your browser"
    echo "  2. Navigate through all pages"
    echo "  3. Check browser console for 404 errors"
fi

echo ""
echo "🛑 To stop the server, run: kill $SERVER_PID"
echo "   Or press Ctrl+C and the server will be stopped automatically"

# Trap to cleanup on exit
trap "kill $SERVER_PID 2>/dev/null || true" EXIT

# Keep script running so server stays up
echo ""
echo "Server is running. Press Ctrl+C to stop..."
wait $SERVER_PID

