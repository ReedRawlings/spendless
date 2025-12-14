# API Keys Configuration

This directory contains configuration files for API keys. **Never commit actual API keys to git.**

## Setup Instructions

1. Copy `Template.xcconfig` to `Debug.xcconfig` and `Release.xcconfig`:
   ```bash
   cp Config/Template.xcconfig Config/Debug.xcconfig
   cp Config/Template.xcconfig Config/Release.xcconfig
   ```

2. Edit each file and replace the placeholder values with your actual API keys:
   - `REVENUECAT_API_KEY`: Get from [RevenueCat Dashboard](https://app.revenuecat.com) (fallback if worker URL is not set)
   - `REVENUECAT_WORKER_URL`: (Recommended) Set to your deployed Cloudflare Worker endpoint URL that returns the API key. The worker should return JSON: `{"api_key": "your_revenuecat_api_key"}`. Example: `https://revenuecat-key.your-subdomain.workers.dev`
   - `SUPERWALL_API_KEY`: Get from [Superwall Dashboard](https://superwall.com/dashboard)
   - `MAILERLITE_WORKER_URL`: Set to your deployed Cloudflare Worker endpoint URL (e.g., `https://spendless-email.your-subdomain.workers.dev`)

3. In Xcode:
   - Go to Project → Info → Configurations
   - Set Debug configuration to use `Config/Debug.xcconfig`
   - Set Release configuration to use `Config/Release.xcconfig`

4. Add these keys to your `Info.plist`:
   ```xml
   <key>REVENUECAT_API_KEY</key>
   <string>$(REVENUECAT_API_KEY)</string>
   <key>REVENUECAT_WORKER_URL</key>
   <string>$(REVENUECAT_WORKER_URL)</string>
   <key>SUPERWALL_API_KEY</key>
   <string>$(SUPERWALL_API_KEY)</string>
   <key>MAILERLITE_WORKER_URL</key>
   <string>$(MAILERLITE_WORKER_URL)</string>
   ```

## Security Notes

- The actual config files (`Debug.xcconfig`, `Release.xcconfig`) are gitignored
- Only `Template.xcconfig` is committed to show the required format
- For CI/CD, inject these values as environment variables in your build pipeline
