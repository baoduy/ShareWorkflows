# Release v10.0.0

## Overview
This is the initial major version release of ShareWorkflows, establishing v10.0.0 as the baseline version for the repository.

## What's New

### New Test Workflow
- Added `dotnet-nuget-test.yml` - A testing-focused workflow based on the existing .NET NuGet release workflow
- This workflow is designed specifically for testing purposes without publishing to any registries
- Key features:
  - Builds and tests .NET projects
  - Generates version numbers using semantic versioning
  - Creates NuGet packages without publishing
  - Uploads test packages as artifacts with 7-day retention
  - Can be manually triggered via workflow_dispatch
  - Can be called from other workflows

### Documentation Updates
- Updated README.md with comprehensive documentation for the new test workflow
- Added usage examples for both workflow_call and workflow_dispatch triggers
- Updated features section to include the test workflow capabilities

## Workflow Comparison

### dotnet-nuget-release.yml (Production)
- Publishes to GitHub Packages
- Publishes to NuGet.org (optional)
- Creates GitHub releases
- Requires authentication tokens

### dotnet-nuget-test.yml (Testing)
- No publishing to any registries
- No release creation
- Minimal required secrets
- Outputs packages to temporary directory
- Uploads artifacts for review

## Breaking Changes
None - this is the initial versioned release.

## Migration Guide
If you're upgrading from an unversioned state:
- No changes required to existing workflow usage
- The new test workflow is optional and can be adopted at your convenience

## Requirements
- .NET SDK 9.x (default, configurable)
- GitHub Actions environment

## Contributors
Special thanks to all contributors who helped establish this baseline version.

---

**Full Changelog**: Initial release at v10.0.0
