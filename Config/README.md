# API Keys Configuration

This directory contains configuration files for API keys. **Never commit actual API keys to git.**

## Setup Instructions

1. Copy `Template.xcconfig` to `Debug.xcconfig` and `Release.xcconfig`:
   ```bash
   cp Config/Template.xcconfig Config/Debug.xcconfig
   cp Config/Template.xcconfig Config/Release.xcconfig
   ```

2. Edit each file and replace the placeholder values with your actual API keys:
   - `REVENUECAT_API_KEY`: Get from [RevenueCat Dashboard](https://app.revenuecat.com)
   - `SUPERWALL_API_KEY`: Get from [Superwall Dashboard](https://superwall.com/dashboard)
   - `CONVERTKIT_API_KEY`: Get from [ConvertKit Settings](https://app.convertkit.com/account_settings/developer_settings)
   - `CONVERTKIT_FORM_ID`: Get from your ConvertKit form settings

3. In Xcode:
   - Go to Project → Info → Configurations
   - Set Debug configuration to use `Config/Debug.xcconfig`
   - Set Release configuration to use `Config/Release.xcconfig`

4. Add these keys to your `Info.plist`:
   ```xml
   <key>REVENUECAT_API_KEY</key>
   <string>$(REVENUECAT_API_KEY)</string>
   <key>SUPERWALL_API_KEY</key>
   <string>$(SUPERWALL_API_KEY)</string>
   <key>CONVERTKIT_API_KEY</key>
   <string>$(CONVERTKIT_API_KEY)</string>
   <key>CONVERTKIT_FORM_ID</key>
   <string>$(CONVERTKIT_FORM_ID)</string>
   ```

## Security Notes

- The actual config files (`Debug.xcconfig`, `Release.xcconfig`) are gitignored
- Only `Template.xcconfig` is committed to show the required format
- For CI/CD, inject these values as environment variables in your build pipeline
