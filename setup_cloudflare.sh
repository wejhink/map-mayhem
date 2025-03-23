#!/bin/bash
# Script to help with the initial setup of Cloudflare Pages for Map Mayhem

# Set text colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   Map Mayhem - Cloudflare Pages Setup   ${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Check if user has a Cloudflare account
echo -e "${YELLOW}Do you already have a Cloudflare account? (y/n)${NC}"
read has_account

if [[ $has_account != "y" && $has_account != "Y" ]]; then
    echo -e "${GREEN}Let's create a Cloudflare account:${NC}"
    echo "1. Open https://dash.cloudflare.com/sign-up in your browser"
    echo "2. Follow the sign-up process"
    echo "3. Verify your email address"
    echo ""
    echo -e "${YELLOW}Press Enter when you've created your account...${NC}"
    read -p ""
fi

# Get Cloudflare account ID
echo -e "${GREEN}Let's find your Cloudflare Account ID:${NC}"
echo "1. Log in to your Cloudflare dashboard at https://dash.cloudflare.com"
echo "2. Look at the URL in your browser address bar"
echo "3. It should look like: https://dash.cloudflare.com/ACCOUNT_ID"
echo "   Where ACCOUNT_ID is a long alphanumeric string"
echo ""
echo -e "${YELLOW}Enter your Cloudflare Account ID:${NC}"
read account_id

# Create API token
echo -e "${GREEN}Now let's create an API token for GitHub Actions:${NC}"
echo "1. Go to https://dash.cloudflare.com/profile/api-tokens"
echo "2. Click 'Create Token'"
echo "3. Select 'Create Custom Token'"
echo "4. Name your token 'GitHub Actions - Map Mayhem'"
echo "5. Under Permissions, add:"
echo "   - Account > Cloudflare Pages > Edit"
echo "   - Zone > Zone Settings > Read"
echo "6. Under Account Resources, select your account"
echo "7. Click 'Continue to summary' and then 'Create Token'"
echo ""
echo -e "${YELLOW}Enter your Cloudflare API Token:${NC}"
read api_token

# Create Cloudflare Pages project
echo -e "${GREEN}Let's create a Cloudflare Pages project:${NC}"
echo "1. Go to https://dash.cloudflare.com/${account_id}/pages"
echo "2. Click 'Create a project'"
echo "3. Choose 'Connect to Git'"
echo "4. Select your GitHub repository"
echo "5. Configure your build settings:"
echo "   - Framework preset: None"
echo "   - Build command: flutter build web --release --dart-define=FLUTTER_WEB_RENDERER=canvaskit"
echo "   - Build output directory: build/web"
echo "6. Click 'Save and Deploy'"
echo ""
echo -e "${YELLOW}What name did you give your Cloudflare Pages project?${NC}"
read project_name

# Create GitHub secrets
echo -e "${GREEN}Now let's add the secrets to your GitHub repository:${NC}"
echo "1. Go to your GitHub repository"
echo "2. Navigate to Settings > Secrets and variables > Actions"
echo "3. Add the following secrets:"
echo "   - Name: CLOUDFLARE_API_TOKEN"
echo "     Value: ${api_token}"
echo "   - Name: CLOUDFLARE_ACCOUNT_ID"
echo "     Value: ${account_id}"
echo ""

# Update GitHub Actions workflow
echo -e "${GREEN}Let's update the GitHub Actions workflow file:${NC}"
echo "1. Open .github/workflows/cloudflare-pages-deploy.yml"
echo "2. Update the projectName value to: ${project_name}"
echo ""

# Summary
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}             Setup Summary              ${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}Cloudflare Account ID:${NC} ${account_id}"
echo -e "${GREEN}Cloudflare Pages Project:${NC} ${project_name}"
echo -e "${GREEN}API Token:${NC} ${api_token:0:5}...${api_token: -5} (partially hidden for security)"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Commit and push your changes to GitHub"
echo "2. The GitHub Actions workflow will automatically build and deploy your app"
echo "3. Check the Actions tab in your GitHub repository for build status"
echo "4. Once deployed, your app will be available at: https://${project_name}.pages.dev"
echo ""
echo -e "${GREEN}For more details, refer to CLOUDFLARE_DEPLOYMENT.md${NC}"
echo ""
