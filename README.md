# ShareWorkflows

A collection of reusable GitHub Actions workflows for Docker publishing, .NET NuGet releases, NPM package publishing, and testing. These workflows provide automated versioning, multi-platform support, and streamlined CI/CD pipelines for your projects.

## Getting Started

### Quick Start
1. **Reference the workflow** in your repository's `.github/workflows` directory
2. **Use a specific version tag** (e.g., `@v10.0.0`) for stability
3. **Configure required secrets** in your repository settings
4. **Provide necessary parameters** based on your project needs

### Version Pinning
Always use a specific version tag instead of `@main` for production workflows:
```yaml
uses: baoduy/ShareWorkflows/.github/workflows/docker-publish.yaml@v10.0.0
```

This ensures your builds remain stable even when the workflows are updated.

## Available Workflows

### 1. Docker Publish
This workflow builds and publishes Docker images to Docker Hub (or other registries) with multi-platform support, automatic versioning, and caching capabilities.

**Workflow file:** `.github/workflows/docker-publish.yaml`

#### Parameters

##### Input Parameters
| Parameter | Description | Required | Default Value |
|-----------|-------------|----------|---------------|
| dockerFile | The location of the Dockerfile | Yes | - |
| imageName | The name of the docker image | Yes | - |
| readMeFile | The location of the README.md | No | - |
| context | The context path of the project | No | . |
| platforms | The docker platforms parameter | No | linux/arm64,linux/amd64 |
| version | The version of the image | No | $(date +%s) |
| buildArgs | Docker build arguments (format: ARG1=value1,ARG2=value2) | No | - |
| DOCKER_REGISTRY | The registry image repository | No | docker.io |
| dockerCacheEnabled | Whether to enable docker cache | No | true |

##### Secret Parameters
| Secret | Description | Required |
|--------|-------------|----------|
| DOCKER_USERNAME | The docker hub user name | Yes |
| DOCKER_TOKEN | The docker hub PAT token | Yes |

#### Usage Example:
```yaml
name: Docker Build and Publish

on:
  push:
    branches: [main]

jobs:
  docker:
    uses: baoduy/ShareWorkflows/.github/workflows/docker-publish.yaml@v10.0.0
    with:
      dockerFile: ./Dockerfile
      imageName: your-dockerhub-username/app-name
      readMeFile: ./README.md
      version: 1.0.0
      platforms: linux/arm64,linux/amd64
      buildArgs: NODE_ENV=production,API_KEY=value
    secrets:
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_TOKEN: ${{ secrets.DOCKER_TOKEN }}
```

### 2. .NET NuGet Release
This workflow builds, tests (optional), and publishes .NET packages to GitHub Packages and/or NuGet.org with automatic semantic versioning.

**Workflow file:** `.github/workflows/dotnet-nuget-release.yml`

#### Parameters

##### Input Parameters
| Parameter | Description | Required | Default Value |
|-----------|-------------|----------|---------------|
| Project_Path | The path to the .NET project file | Yes | - |
| Enable_Release | Enable GitHub release creation | No | - |
| Enable_Nuget_Release | Enable publishing to NuGet.org | No | - |
| Dotnet_Version | The .NET version to use | No | 9.x |

##### Secret Parameters
| Secret | Description | Required |
|--------|-------------|----------|
| PACKAGE_TOKEN | GitHub packages token | Yes |
| NUGET_PACKAGE_TOKEN | NuGet.org API key | Yes |

#### Usage Example:
```yaml
name: Release NuGet Package

on:
  push:
    branches: [main]

jobs:
  nuget:
    uses: baoduy/ShareWorkflows/.github/workflows/dotnet-nuget-release.yml@v10.0.0
    with:
      Project_Path: ./src/MyProject/MyProject.csproj
      Enable_Release: true              # Publish to GitHub Packages
      Enable_Nuget_Release: true        # Publish to NuGet.org
      Dotnet_Version: 9.x
    secrets:
      PACKAGE_TOKEN: ${{ secrets.PACKAGE_TOKEN }}
      NUGET_PACKAGE_TOKEN: ${{ secrets.NUGET_PACKAGE_TOKEN }}
```

### 2a. .NET NuGet Test
This workflow is designed for testing .NET projects without publishing. It builds, tests, and packages projects to validate the workflow and packaging steps. Perfect for pull request validation and testing before production releases.

**Workflow file:** `.github/workflows/dotnet-nuget-test.yml`

#### Parameters

##### Input Parameters
| Parameter | Description | Required | Default Value |
|-----------|-------------|----------|---------------|
| Project_Path | The path to the .NET project file | Yes | - |
| Dotnet_Version | The .NET version to use | No | 9.x |

#### Usage Example (Workflow Call):
```yaml
name: Test .NET Package

on:
  pull_request:
    branches: [main]

jobs:
  nuget-test:
    uses: baoduy/ShareWorkflows/.github/workflows/dotnet-nuget-test.yml@v10.0.0
    with:
      Project_Path: ./src/MyProject/MyProject.csproj
      Dotnet_Version: 9.x
```

#### Usage Example (Manual Trigger):
```yaml
name: Test .NET Package

on:
  workflow_dispatch:
    inputs:
      Project_Path:
        description: 'Path to .NET project file'
        required: true
        default: './src/MyProject/MyProject.csproj'
      Dotnet_Version:
        description: 'The .NET version to use'
        required: false
        default: '9.x'

jobs:
  test:
    uses: baoduy/ShareWorkflows/.github/workflows/dotnet-nuget-test.yml@v10.0.0
    with:
      Project_Path: ${{ inputs.Project_Path }}
      Dotnet_Version: ${{ inputs.Dotnet_Version }}
```

#### Features
- Builds and tests .NET projects
- Generates version numbers using semantic versioning
- Creates NuGet packages without publishing
- Uploads test packages as artifacts (7-day retention)
- No automated releases or publishing to registries
- Can be manually triggered for testing purposes

### 3. NPM Package Publish
This workflow builds and publishes NPM packages with automatic semantic versioning. It includes Node module caching for faster builds and supports large build spaces.

**Workflow file:** `.github/workflows/npm-publish.yaml`

#### Parameters

##### Input Parameters
This workflow has no required input parameters. All configuration is handled automatically based on your repository's `package.json`.

##### Secret Parameters
| Secret | Description | Required |
|--------|-------------|----------|
| NPM_TOKEN | NPM access token for publishing | Yes |
| GITHUB_TOKEN | GitHub token (automatically provided) | Auto |

#### Usage Example:
```yaml
name: Publish NPM Package

on:
  push:
    branches: [main]

jobs:
  npm:
    uses: baoduy/ShareWorkflows/.github/workflows/npm-publish.yaml@v10.0.0
    secrets:
      NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

**Note:** This workflow expects:
- A `package.json` in your repository root
- A `build` script in your package.json
- Build output in a `.out-bin` directory

## Features

### All Workflows
- **Semantic Versioning**: Automatic version calculation using git tags with support for MAJOR, MINOR, and PATCH bumps (see [VERSIONING.md](VERSIONING.md))
- **Git Integration**: Automatic checkout with full history and tag support
- **Configurable**: Flexible input parameters to customize behavior

### Docker Publish
- **Multi-Platform Support**: Build for arm64 and amd64 architectures simultaneously
- **Registry Flexibility**: Support for Docker Hub and other container registries
- **Automatic Version Tagging**: Creates both versioned and `latest` tags
- **README Integration**: Automatically updates Docker Hub repository description
- **Build Arguments**: Pass custom build arguments to Docker build
- **Cache Optimization**: Optional Docker layer caching for faster builds
- **QEMU Support**: Cross-platform build support using QEMU emulation

### .NET NuGet Release
- **Semantic Versioning**: Automatic version calculation using git tags
- **Dual Publishing**: Publish to GitHub Packages and/or NuGet.org
- **Flexible Release Control**: Enable/disable GitHub releases and NuGet.org publishing independently
- **Automated Release Creation**: Creates GitHub releases with generated release notes
- **Code Coverage**: Collects code coverage during test execution
- **Package Validation**: Validates package creation before publishing
- **Multi-Version Support**: Configurable .NET SDK version (default: 9.x)
- **Dependency Management**: Automatic restoration of NuGet dependencies

### .NET NuGet Test
- **Testing-Only Workflow**: Validates packaging without publishing to any registry
- **Automatic Versioning**: Shows what version would be created (semantic versioning)
- **Code Coverage Collection**: Runs tests with code coverage collection
- **Package Validation**: Ensures project can be packaged correctly
- **Artifact Upload**: Uploads test packages as artifacts (7-day retention)
- **Multiple Trigger Options**: Supports workflow_call, workflow_dispatch, and automatic push triggers
- **Read-Only Permissions**: Minimal permissions for safe testing
- **Manual Testing**: Can be triggered manually from GitHub UI with custom inputs

### NPM Package Publish
- **Semantic Versioning**: Automatic version calculation using git tags
- **Node Module Caching**: Caches dependencies for faster subsequent builds
- **Automated Release Creation**: Creates GitHub releases when enabled
- **Public NPM Publishing**: Publishes to public NPM registry
- **Large Build Space**: Allocates 4GB heap size for large builds
- **Package.json Version Update**: Automatically updates version in output package
- **Node 20 Support**: Uses latest Node.js LTS version

## Semantic Versioning

All workflows use automatic semantic versioning based on git tags. The version is calculated using the `paulhatch/semantic-version` action.

### How It Works
1. The action scans existing git tags to find the latest version
2. By default, it increments the **patch** version (e.g., 1.2.3 → 1.2.4)
3. You can control version bumps through commit messages:
   - **Patch**: No keyword needed (e.g., `1.2.3 → 1.2.4`) - Bug fixes
   - **Minor**: Include `(MINOR)` in commit message (e.g., `1.2.3 → 1.3.0`) - New features
   - **Major**: Include `(MAJOR)` in commit message (e.g., `1.2.3 → 2.0.0`) - Breaking changes

### Examples
```bash
# Patch version bump (default)
git commit -m "Fix: resolve Docker build issue"

# Minor version bump
git commit -m "Feature: add build arguments support (MINOR)"

# Major version bump
git commit -m "Breaking: change workflow parameter names (MAJOR)"
```

For more details, see [VERSIONING.md](VERSIONING.md).

## Workflow Comparison

For detailed comparison between the `.NET NuGet Release` and `.NET NuGet Test` workflows, see [WORKFLOW_COMPARISON.md](.github/workflows/WORKFLOW_COMPARISON.md).

## Requirements

### Docker Publish
1. **Docker Hub account** (or other container registry account)
2. **Docker Hub Personal Access Token (PAT)** with read/write permissions
3. **Dockerfile** in your repository
4. *Optional:* README.md for Docker Hub description

### .NET NuGet Release
1. **GitHub Personal Access Token** with `packages:write` permission
2. **NuGet.org API Key** (only if publishing to NuGet.org)
3. **.NET project** with proper package configuration
4. **Git tags** for versioning (or will start from 0.1.0)

### .NET NuGet Test
1. **.NET project** with proper package configuration
2. **Git tags** for versioning (or will start from 0.1.0)
3. No authentication tokens required (uses automatic GITHUB_TOKEN)

### NPM Package Publish
1. **NPM account** with publishing permissions
2. **NPM Access Token** with automation access level
3. **package.json** with build script
4. **Git tags** for versioning (or will start from 0.1.0)
5. Build output should be in `.out-bin` directory

## Best Practices

### Workflow Security
- **Use Repository Secrets**: Store all tokens and credentials as repository secrets
- **Limit Token Permissions**: Grant minimum necessary permissions to tokens
- **Version Pinning**: Use specific version tags (e.g., `@v10.0.0`) instead of `@main`

### Versioning Strategy
- **Tag Your Releases**: Create git tags for releases (e.g., `v1.2.3`)
- **Use Semantic Versioning**: Follow [semver](https://semver.org/) principles
- **Control Version Bumps**: Use `(MINOR)` or `(MAJOR)` in commit messages when needed

### Development Workflow
1. **Test First**: Use the `.NET NuGet Test` workflow before releasing
2. **Review Artifacts**: Check uploaded artifacts before publishing
3. **Gradual Rollout**: Enable GitHub Packages first, then NuGet.org after validation
4. **Monitor Builds**: Review workflow logs for any warnings or issues

### Performance Optimization
- **Enable Docker Caching**: Use `dockerCacheEnabled: true` for faster Docker builds
- **Node Module Caching**: Automatically enabled in NPM workflow
- **Dependency Caching**: Leverage NuGet package caching

## Troubleshooting

### Common Issues

#### Version Not Incrementing
- **Cause**: No git tags exist in repository
- **Solution**: Create your first tag: `git tag v1.0.0 && git push origin v1.0.0`

#### Docker Build Fails
- **Cause**: Multi-platform build issues or missing QEMU
- **Solution**: Workflow includes QEMU setup automatically; check Dockerfile compatibility

#### NuGet Push Fails
- **Cause**: Invalid token or insufficient permissions
- **Solution**: Verify `PACKAGE_TOKEN` has `packages:write` permission

#### NPM Publish Fails
- **Cause**: Build output not in expected directory
- **Solution**: Ensure your build outputs to `.out-bin` directory or modify workflow

#### Semantic Version Calculation Error
- **Cause**: Improper tag format
- **Solution**: Ensure tags follow `vX.Y.Z` format (e.g., `v1.2.3`)

### Getting Help
1. Check existing [issues](https://github.com/baoduy/ShareWorkflows/issues)
2. Review [VERSIONING.md](VERSIONING.md) for version-related questions
3. Review [WORKFLOW_COMPARISON.md](.github/workflows/WORKFLOW_COMPARISON.md) for .NET workflow differences
4. Create a new issue with:
   - Workflow file you're using
   - Error messages or unexpected behavior
   - Your repository structure (if relevant)

## Contributing
We welcome contributions! Feel free to:
- Submit pull requests with improvements
- Create issues for bug reports
- Request new features
- Improve documentation

Please ensure your contributions:
- Follow existing code style
- Include clear descriptions
- Update documentation as needed

## License
This project is licensed under the MIT License - see the LICENSE file for details.