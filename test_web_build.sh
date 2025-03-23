#!/bin/bash
# Script to test Flutter web build locally before deploying to Cloudflare Pages

# Set error handling
set -e

echo "🔍 Checking Flutter version..."
flutter --version

echo "📦 Getting dependencies..."
flutter pub get


echo "🏗️ Building web application..."
flutter build web --release --web-renderer canvaskit \
--dart-define=FLUTTER_WEB_USE_SKIA=true \
--dart-define=FLUTTER_WEB_AUTO_DETECT=false

echo "✅ Build completed successfully!"
echo "📁 Web build output is in: $(pwd)/build/web"

# Check for serviceWorkerVersion issue and fix if needed
echo "🔍 Checking for serviceWorkerVersion issue..."
if ! grep -q "serviceWorkerVersion" build/web/flutter_service_worker.js 2>/dev/null; then
  echo "⚠️ serviceWorkerVersion not found in service worker, applying fix..."
  # Create a simple version if it doesn't exist
  TIMESTAMP=$(date +%s)
  echo "const serviceWorkerVersion = '$TIMESTAMP';" > build/web/version.js
  # Update index.html to include the version file
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS requires different sed syntax
    sed -i '' 's/<script src="flutter_bootstrap.js"/<script src="version.js"><\/script><script src="flutter_bootstrap.js"/' build/web/index.html
  else
    # Linux/Windows
    sed -i 's/<script src="flutter_bootstrap.js"/<script src="version.js"><\/script><script src="flutter_bootstrap.js"/' build/web/index.html
  fi
  echo "✅ Fix applied successfully!"
else
  echo "✅ No serviceWorkerVersion issues detected."
fi

# Check if Python is available for local server
if command -v python3 &> /dev/null; then
    echo "🚀 Starting local server with Python..."
    echo "🌐 Open http://localhost:8000 in your browser"
    cd build/web && python3 -m http.server
elif command -v python &> /dev/null; then
    echo "🚀 Starting local server with Python..."
    echo "🌐 Open http://localhost:8000 in your browser"
    cd build/web && python -m http.server
else
    echo "⚠️ Python not found. To test locally, you can:"
    echo "  1. Install Python, or"
    echo "  2. Use 'npx serve build/web', or"
    echo "  3. Open build/web/index.html directly in your browser"
fi
