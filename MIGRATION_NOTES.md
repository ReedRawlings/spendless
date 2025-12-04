# SwiftData Migration Notes

## Current Status: Pre-Launch (No Users)

Since we have **no users currently**, we've implemented a simple schema versioning system that automatically resets the database when the schema changes.

## How It Works

1. **Schema Version**: Defined in `SpendLessApp.swift` as `currentSchemaVersion = 2`
2. **Automatic Reset**: On app launch, checks if saved schema version matches current version
3. **Database Reset**: If versions don't match, deletes all database files and recreates with new schema
4. **Version Tracking**: Stores schema version in `UserDefaults.standard`

## Schema Changes Made

**Version 2** (Current):
- Added `@Attribute(.unique)` to `UserProfile.id`
- Added `@Attribute(.unique)` to `Streak.id`
- Added singleton IDs to both models

**Version 1** (Previous):
- Initial schema

## Testing

Before launch, test:
1. ✅ App launches successfully with new schema
2. ✅ Database resets correctly when schema version changes
3. ✅ Data persists correctly after reset
4. ✅ No duplicate UserProfile/Streak records are created

## After Launch

**IMPORTANT**: Once you have users, you **MUST** implement proper SwiftData migrations:

1. Remove the automatic reset logic
2. Implement `ModelVersion` enum:
   ```swift
   enum SpendLessSchemaVersion: VersionedSchema {
       static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)
       // ... schema definitions
   }
   ```

3. Use `ModelConfiguration` with migration:
   ```swift
   let configuration = ModelConfiguration(
       schema: schema,
       migrationPlan: SpendLessMigrationPlan.self
   )
   ```

4. Create migration plan:
   ```swift
   enum SpendLessMigrationPlan: SchemaMigrationPlan {
       static var schemas: [any VersionedSchema.Type] {
           [SpendLessSchemaVersion.self]
       }
       
       static var stages: [MigrationStage] {
           [migrateV1toV2]
       }
   }
   ```

## Current Implementation

The current implementation is in `SpendLessApp.swift`:
- `currentSchemaVersion` - tracks schema version
- `resetDatabase()` - deletes database files
- Automatic reset on version mismatch

This is **safe** for pre-launch but **must be replaced** before shipping to production with real users.
