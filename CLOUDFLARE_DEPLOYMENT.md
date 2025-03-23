# Deploying Map Mayhem to Cloudflare Pages

This guide provides step-by-step instructions for deploying the Map Mayhem Flutter web application to Cloudflare Pages using multiple approaches:

1. **GitHub Actions CI/CD** - Automated builds and deployments triggered by code pushes
2. **Direct Upload** - Build locally and deploy directly using Cloudflare Wrangler CLI
3. **Manual Upload** - Build locally and upload through the Cloudflare Pages dashboard

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.5.3 or compatible)
- [Git](https://git-scm.com/downloads)
- A [Cloudflare account](https://dash.cloudflare.com/sign-up)
- A GitHub repository for your project (for CI/CD deployment)

## Deployment Methods

### Method 1: Direct Upload with Wrangler CLI (Recommended)

This method builds your Flutter web app locally and deploys it directly to Cloudflare Pages using the Wrangler CLI. This approach avoids issues with GitHub Actions and Cloudflare's build environment.

1. **Run the direct upload script**:

   ```bash
   ./direct_upload_to_cloudflare.sh
   ```

   This script will:

   - Check for Flutter and Wrangler CLI installation
   - Build your Flutter web app with optimized settings
   - Fix any serviceWorkerVersion issues
   - Deploy directly to Cloudflare Pages

2. **First-time setup**:
   - You'll be prompted to log in to Cloudflare if not already authenticated
   - Enter your Cloudflare Pages project name when prompted
   - The script will handle the rest of the deployment process

### Method 2: Manual Upload via Cloudflare Dashboard

This method involves building the Flutter web app locally and then uploading it through the Cloudflare Pages dashboard.

1. **Build the Flutter Web Application**:

   ```bash
   # Ensure you're using the correct Flutter version
   flutter --version

   # Get dependencies
   flutter pub get

   # Build the web application with optimized settings
   flutter build web --release --dart-define=FLUTTER_WEB_RENDERER=canvaskit
   ```

2. **Deploy to Cloudflare Pages**:
   - Log in to your [Cloudflare Dashboard](https://dash.cloudflare.com/)
   - Navigate to **Pages** in the sidebar
   - Click **Create a project**
   - Choose **Direct Upload** as your deployment method
   - Drag and drop the contents of your `build/web` directory
   - Click **Deploy site**

### Method 3: GitHub Actions CI/CD

This method uses GitHub Actions to automatically build and deploy your Flutter web app to Cloudflare Pages whenever you push to your repository.

> **Note**: If you encounter Flutter version issues with GitHub Actions, consider using Method 1 or 2 instead.

1. **Set Up Cloudflare Pages Project**:
   - Log in to your [Cloudflare Dashboard](https://dash.cloudflare.com/)
   - Navigate to **Pages** in the sidebar
   - Click **Create a project**
   - Choose **Connect to Git** as your deployment method
   - Select your GitHub repository
   - For the build settings, select **None** (we'll use GitHub Actions instead)
   - Click **Save and Deploy** (the initial deployment will fail, which is expected)

### 2. Create Cloudflare API Token

1. In your Cloudflare Dashboard, go to **My Profile** > **API Tokens**
2. Click **Create Token**
3. Select **Create Custom Token**
4. Name your token (e.g., "GitHub Actions - Map Mayhem")
5. Under **Permissions**, add:
   - Account > Cloudflare Pages > Edit
   - Zone > Zone Settings > Read
6. Under **Account Resources**, select your account
7. Under **Zone Resources**, select "All zones" or specific zones if needed
8. Click **Continue to summary** and then **Create Token**
9. Copy the token value (you won't be able to see it again)

### 3. Add Secrets to GitHub Repository

1. Go to your GitHub repository
2. Navigate to **Settings** > **Secrets and variables** > **Actions**
3. Add the following secrets:
   - `CLOUDFLARE_API_TOKEN`: Your Cloudflare API token
   - `CLOUDFLARE_ACCOUNT_ID`: Your Cloudflare account ID (found in the Cloudflare dashboard URL)

### 4. GitHub Actions Workflow

The GitHub Actions workflow file (`.github/workflows/cloudflare-pages-deploy.yml`) is already set up in your repository. It will:

1. Set up Flutter environment
2. Install dependencies
3. Run tests
4. Build the web application
5. Deploy to Cloudflare Pages

## Troubleshooting

### Common Issues

1. **Build Failures**:

   - Ensure Flutter version is compatible (3.5.3 or compatible)
   - Check for any package compatibility issues with `flutter pub outdated`

2. **Deployment Failures**:

   - Verify API token permissions
   - Check account ID is correct
   - Ensure project name in workflow matches Cloudflare Pages project name

3. **Web Rendering Issues**:

   - If maps don't render correctly, try switching to HTML renderer for debugging
   - Check browser console for any JavaScript errors

4. **serviceWorkerVersion Error**:
   - If you see `Uncaught ReferenceError: serviceWorkerVersion is not defined` in the console:
     - This is a common issue with Flutter web builds
     - Our deployment workflow includes a fix for this issue
     - For local testing, you can add `var serviceWorkerVersion = null;` before the Flutter initialization code
     - The error occurs because the variable is expected to be injected during the build process but sometimes isn't

### Useful Commands

```bash
# Check Flutter version
flutter --version

# Upgrade Flutter
flutter upgrade

# Clean build cache
flutter clean

# Analyze project for issues
flutter analyze

# Run tests
# flutter test
```

## Custom Domain Setup (Optional)

1. In Cloudflare Pages, go to your project
2. Navigate to **Custom domains**
3. Click **Set up a custom domain**
4. Enter your domain name and follow the instructions
5. Update DNS settings as directed by Cloudflare

## Performance Optimization

The deployment is already configured with:

- CanvasKit renderer for optimal map performance
- Asset caching headers for improved load times
- Gzip compression for reduced file sizes
- Loading indicator for better user experience

## Support

If you encounter any issues with the deployment, please:

1. Check the GitHub Actions logs for error messages
2. Review the Cloudflare Pages deployment logs
3. Consult the [Cloudflare Pages documentation](https://developers.cloudflare.com/pages/)
4. Refer to the [Flutter web deployment documentation](https://docs.flutter.dev/deployment/web)
