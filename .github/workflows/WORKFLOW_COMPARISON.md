# Workflow Comparison: Release vs Test

## Overview
This document compares the `.NET nuget release` workflow with the `.NET nuget test` workflow to help users understand when to use each.

## Quick Reference

| Feature | dotnet-nuget-release.yml | dotnet-nuget-test.yml |
|---------|-------------------------|----------------------|
| **Purpose** | Production releases | Testing and validation |
| **Trigger** | `workflow_call` | `workflow_call` + `workflow_dispatch` |
| **Publishing** | ✅ GitHub Packages, NuGet.org | ❌ No publishing |
| **Release Creation** | ✅ Optional | ❌ Disabled |
| **Package Output** | Workspace (`runner.WORKSPACE`) | Temp dir (`runner.temp`) |
| **Artifact Upload** | ❌ No | ✅ Yes (7-day retention) |
| **Permissions** | `write` (contents, packages) | `read` (contents, packages) |
| **Required Secrets** | PACKAGE_TOKEN, NUGET_PACKAGE_TOKEN | PACKAGE_TOKEN (optional) |

## Detailed Comparison

### Trigger Events

#### Release Workflow
```yaml
on:
  workflow_call:
    inputs:
      Enable_Release: ...
      Enable_Nuget_Release: ...
```
- Only callable from other workflows
- No manual trigger option

#### Test Workflow
```yaml
on:
  workflow_dispatch:
    inputs:
      Project_Path: ...
  workflow_call:
    inputs:
      Project_Path: ...
```
- Callable from other workflows
- Can be manually triggered from GitHub UI
- Simpler input parameters (no release flags)

### Package Output Location

#### Release Workflow
```yaml
- name: Package
  run: dotnet pack ... --output ${{ runner.WORKSPACE }}/nupkgs
```
- Outputs to workspace directory
- Used for subsequent publishing steps

#### Test Workflow
```yaml
- name: Package
  run: dotnet pack ... --output ${{ runner.temp }}/test-nupkgs
```
- Outputs to temporary directory
- Clearly marked as test packages
- Automatically cleaned up

### Publishing Steps

#### Release Workflow
Has these additional steps:
1. **Zip Release** - Creates release.zip
2. **Publish** - Pushes to GitHub Packages (when `Enable_Release == 'true'`)
3. **Release** - Creates GitHub release (when `Enable_Release == 'true'`)
4. **Publish Nuget** - Pushes to NuGet.org (when `Enable_Nuget_Release == 'true'`)

#### Test Workflow
Instead of publishing:
```yaml
- name: Upload test artifacts
  uses: actions/upload-artifact@v4
  with:
    name: test-packages
    path: ${{ runner.temp }}/test-nupkgs
    retention-days: 7
```
- Uploads packages as workflow artifacts
- Allows manual inspection
- Automatic cleanup after 7 days

### Permissions

#### Release Workflow
```yaml
permissions:
  contents: write    # For creating releases
  packages: write    # For publishing packages
```

#### Test Workflow
```yaml
permissions:
  contents: read     # Read-only access
  packages: read     # Read-only access
```

### Testing Step

#### Release Workflow
```yaml
- name: Test
  continue-on-error: true
  if: ${{ inputs.Enable_Release != 'true' && inputs.Enable_Nuget_Release != 'true' }}
  run: dotnet test ...
```
- Only runs when NOT releasing
- Skipped during production releases

#### Test Workflow
```yaml
- name: Test
  continue-on-error: true
  run: dotnet test ...
```
- Always runs
- Primary purpose of the workflow

### GitHub NuGet Source

#### Release Workflow
```yaml
- name: Ensure GitHub NuGet Source
  run: |
    dotnet nuget add source ... -p ${{ secrets.GITHUB_TOKEN }}
```
- Always configured
- Required for publishing

#### Test Workflow
```yaml
- name: Ensure GitHub NuGet Source
  if: ${{ secrets.PACKAGE_TOKEN != '' }}
  run: |
    dotnet nuget add source ... -p ${{ secrets.GITHUB_TOKEN }}
```
- Conditionally configured
- Only if PACKAGE_TOKEN is provided
- Useful for private package dependencies

## Use Cases

### Use Release Workflow When:
- ✅ Publishing to GitHub Packages
- ✅ Publishing to NuGet.org
- ✅ Creating official releases
- ✅ Deploying production packages
- ✅ Tagging versions

### Use Test Workflow When:
- ✅ Testing package creation without publishing
- ✅ Validating packaging configuration
- ✅ Running CI/CD tests on pull requests
- ✅ Experimenting with workflow changes
- ✅ Verifying builds before release
- ✅ Testing manually with workflow_dispatch
- ✅ Reviewing package contents before publishing

## Migration Path

### From Manual Testing to Test Workflow
Before:
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup .NET
        uses: actions/setup-dotnet@v5
      # ... manual steps ...
```

After:
```yaml
jobs:
  test:
    uses: baoduy/ShareWorkflows/.github/workflows/dotnet-nuget-test.yml@main
    with:
      Project_Path: ./src/MyProject/MyProject.csproj
```

### From Test Workflow to Release Workflow
When ready to release, simply switch workflows:

```yaml
jobs:
  release:
    uses: baoduy/ShareWorkflows/.github/workflows/dotnet-nuget-release.yml@main
    with:
      Project_Path: ./src/MyProject/MyProject.csproj
      Enable_Release: true
      Enable_Nuget_Release: true
    secrets:
      PACKAGE_TOKEN: ${{ secrets.PACKAGE_TOKEN }}
      NUGET_PACKAGE_TOKEN: ${{ secrets.NUGET_PACKAGE_TOKEN }}
```

## Best Practices

1. **Development Flow**
   - Use test workflow during development
   - Use release workflow for production

2. **Pull Request Checks**
   - Configure test workflow to run on PRs
   - Validates package creation before merge

3. **Manual Testing**
   - Use workflow_dispatch on test workflow
   - Review artifacts before committing to release

4. **Version Control**
   - Both workflows use semantic versioning
   - Test workflow shows what version would be created
   - Release workflow actually creates the tag and release

## Example Workflow Configuration

### For Development/Testing
```yaml
name: Test Package

on:
  pull_request:
    branches: [main]
  workflow_dispatch:

jobs:
  test:
    uses: baoduy/ShareWorkflows/.github/workflows/dotnet-nuget-test.yml@v10.0.0
    with:
      Project_Path: ./src/MyProject/MyProject.csproj
      Dotnet_Version: 9.x
```

### For Production Release
```yaml
name: Release Package

on:
  push:
    branches: [main]

jobs:
  release:
    uses: baoduy/ShareWorkflows/.github/workflows/dotnet-nuget-release.yml@v10.0.0
    with:
      Project_Path: ./src/MyProject/MyProject.csproj
      Enable_Release: true
      Enable_Nuget_Release: false  # Enable when ready for public release
    secrets:
      PACKAGE_TOKEN: ${{ secrets.PACKAGE_TOKEN }}
      NUGET_PACKAGE_TOKEN: ${{ secrets.NUGET_PACKAGE_TOKEN }}
```
