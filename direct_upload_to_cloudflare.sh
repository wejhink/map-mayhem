#!/bin/bash
# Script to build Flutter web app locally and deploy directly to Cloudflare Pages
# This is an alternative to using GitHub Actions or Cloudflare's build environment

# Set error handling
set -e

# Text colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   Map Mayhem - Direct Upload to Cloudflare Pages   ${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo -e "${YELLOW}Cloudflare Wrangler CLI not found. Installing...${NC}"
    npm install -g wrangler
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Flutter not found. Please install Flutter first.${NC}"
    echo "Visit https://flutter.dev/docs/get-started/install for installation instructions."
    exit 1
fi

# Check Flutter version
echo -e "${GREEN}Checking Flutter version...${NC}"
flutter --version

# Clean previous builds
echo -e "${GREEN}Cleaning previous builds...${NC}"
flutter clean

# Get dependencies
echo -e "${GREEN}Getting dependencies...${NC}"
flutter pub get

# Build web app
echo -e "${GREEN}Building Flutter web app...${NC}"
flutter build web --release --dart-define=FLUTTER_WEB_RENDERER=canvaskit

# Check for serviceWorkerVersion issue and fix if needed
echo -e "${GREEN}Checking for serviceWorkerVersion issue...${NC}"
if ! grep -q "serviceWorkerVersion" build/web/flutter_service_worker.js 2>/dev/null; then
  echo -e "${YELLOW}serviceWorkerVersion not found in service worker, applying fix...${NC}"
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
  echo -e "${GREEN}Fix applied successfully!${NC}"
else
  echo -e "${GREEN}No serviceWorkerVersion issues detected.${NC}"
fi

# Optimize assets
echo -e "${GREEN}Optimizing assets...${NC}"
cd build/web
find . -type f -name "*.html" -o -name "*.css" -o -name "*.js" | xargs gzip -9 -k
cd ../..

# Login to Cloudflare if needed
echo -e "${GREEN}Checking Cloudflare authentication...${NC}"
if ! wrangler whoami &> /dev/null; then
    echo -e "${YELLOW}Please login to Cloudflare:${NC}"
    wrangler login
fi

# Ask for project name if not already set
echo -e "${YELLOW}Enter your Cloudflare Pages project name (e.g., map-mayhem):${NC}"
read project_name

# Deploy to Cloudflare Pages
echo -e "${GREEN}Deploying to Cloudflare Pages...${NC}"
cd build/web
wrangler pages deploy . --project-name="$project_name" --branch=production

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "Your app should now be available at: https://${project_name}.pages.dev"
echo ""
echo -e "${YELLOW}Note:${NC} If this is your first deployment, you may need to set up a custom domain in the Cloudflare Pages dashboard."
