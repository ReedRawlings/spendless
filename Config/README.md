# API Keys Configuration

This directory contains configuration files for API keys. **Never commit actual API keys to git.**

## Setup Instructions

1. Copy `Template.xcconfig` to `Debug.xcconfig` and `Release.xcconfig`:
   ```bash
   cp Config/Template.xcconfig Config/Debug.xcconfig
   cp Config/Template.xcconfig Config/Release.xcconfig
   ```

2. Edit each file and replace the placeholder values with your actual API keys:
   - `MAILERLITE_WORKER_URL`: Set to your deployed Cloudflare Worker endpoint URL (e.g., `https://spendless-email.your-subdomain.workers.dev`)

3. In Xcode:
   - Go to Project → Info → Configurations
   - Set Debug configuration to use `Config/Debug.xcconfig`
   - Set Release configuration to use `Config/Release.xcconfig`

4. Add these keys to your `Info.plist`:
   ```xml
   <key>MAILERLITE_WORKER_URL</key>
   <string>$(MAILERLITE_WORKER_URL)</string>
   ```

## Subscriptions

SpendLess uses native StoreKit 2 for subscription management. No API keys are required for subscriptions.

Product IDs are configured in `SpendLess/App/Constants.swift`:
- Monthly: `monthly_699_4daytrial`
- Annual: `monthly_1999_4daytrial`

These product IDs must match the products configured in App Store Connect.

## Security Notes

- The actual config files (`Debug.xcconfig`, `Release.xcconfig`) are gitignored
- Only `Template.xcconfig` is committed to show the required format
- For CI/CD, inject these values as environment variables in your build pipeline
