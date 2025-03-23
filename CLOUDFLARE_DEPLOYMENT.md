# Deploying Map Mayhem to Cloudflare Pages

This guide provides step-by-step instructions for deploying the Map Mayhem Flutter web application to Cloudflare Pages, both manually and using the CI/CD pipeline.

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.5.3 or compatible)
- [Git](https://git-scm.com/downloads)
- A [Cloudflare account](https://dash.cloudflare.com/sign-up)
- A GitHub repository for your project (for CI/CD deployment)

## Manual Deployment

### 1. Build the Flutter Web Application

```bash
# Ensure you're using the correct Flutter version
flutter --version

# Get dependencies
flutter pub get

# Build the web application with optimized settings
flutter build web --release --web-renderer canvaskit \
--dart-define=FLUTTER_WEB_USE_SKIA=true \
--dart-define=FLUTTER_WEB_AUTO_DETECT=false
```

The built web application will be in the `build/web` directory.

### 2. Deploy to Cloudflare Pages

1. Log in to your [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Navigate to **Pages** in the sidebar
3. Click **Create a project**
4. Choose **Direct Upload** as your deployment method
5. Drag and drop the contents of your `build/web` directory
6. Click **Deploy site**

## CI/CD Deployment with GitHub Actions

### 1. Set Up Cloudflare Pages Project

1. Log in to your [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Navigate to **Pages** in the sidebar
3. Click **Create a project**
4. Choose **Connect to Git** as your deployment method
5. Select your GitHub repository
6. Configure your build settings:
   - **Framework preset**: None
   - **Build command**: `flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true --dart-define=FLUTTER_WEB_AUTO_DETECT=false`
   - **Build output directory**: `build/web`
7. Click **Save and Deploy**

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
