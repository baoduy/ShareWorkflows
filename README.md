# ShareWorkflows

A collection of reusable GitHub Actions workflows for Docker publishing, .NET NuGet releases, and NPM package publishing.

## Available Workflows

### 1. Docker Publish
This workflow builds and publishes Docker images to Docker Hub with multi-platform support.

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
jobs:
  docker:
    uses: your-org/ShareWorkflows/.github/workflows/docker-publish.yaml@main
    with:
      dockerFile: ./Dockerfile
      imageName: your-org/app-name
      readMeFile: ./README.md
    secrets:
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_TOKEN: ${{ secrets.DOCKER_TOKEN }}
```

### 2. .NET NuGet Release
This workflow builds, tests, and publishes .NET packages to both GitHub Packages and NuGet.org.

#### Parameters

##### Input Parameters
| Parameter | Description | Required | Default Value |
|-----------|-------------|----------|---------------|
| Project_Path | The path to the .NET project file | Yes | - |
| Enable_Release | Enable GitHub release creation | No | - |
| Enable_Nuget_Release | Enable publishing to NuGet.org | No | - |

##### Secret Parameters
| Secret | Description | Required |
|--------|-------------|----------|
| PACKAGE_TOKEN | GitHub packages token | Yes |
| NUGET_PACKAGE_TOKEN | NuGet.org API key | Yes |

#### Usage Example:
```yaml
jobs:
  nuget:
    uses: your-org/ShareWorkflows/.github/workflows/dotnet-nuget-release.yml@main
    with:
      Project_Path: ./src/MyProject/MyProject.csproj
      Enable_Release: true
      Enable_Nuget_Release: true
    secrets:
      PACKAGE_TOKEN: ${{ secrets.PACKAGE_TOKEN }}
      NUGET_PACKAGE_TOKEN: ${{ secrets.NUGET_PACKAGE_TOKEN }}
```

### 3. NPM Package Publish
This workflow builds and publishes NPM packages with automatic versioning.

#### Parameters

##### Input Parameters
| Parameter | Description | Required | Default Value |
|-----------|-------------|----------|---------------|

##### Secret Parameters
| Secret | Description | Required |
|--------|-------------|----------|

#### Usage Example:
```yaml
jobs:
  npm:
    uses: your-org/ShareWorkflows/.github/workflows/npm-publish.yaml@main
    with:
      dockerFile: ./Dockerfile
      imageName: your-org/npm-package
    secrets:
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_TOKEN: ${{ secrets.DOCKER_TOKEN }}
      NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

## Features

### Docker Publish
- Multi-platform build support (arm64/amd64)
- Automatic version tagging
- README.md integration with Docker Hub
- Build arguments support
- Cache optimization
- Secure secret handling

### .NET NuGet Release
- Automatic versioning using git tags
- GitHub Packages publishing
- Optional NuGet.org publishing
- Automated release creation
- Code coverage collection
- Package version management

### NPM Package Publish
- Automatic versioning using git tags
- Node modules caching
- Automated release creation
- Public NPM registry publishing
- Large build space allocation
- Package.json version updating

## Requirements

### Docker Publish
1. Docker Hub account
2. Docker Hub Personal Access Token (PAT)

### .NET NuGet Release
1. GitHub Personal Access Token with packages permission
2. NuGet.org API Key (if publishing to NuGet.org)

### NPM Package Publish
1. NPM account
2. NPM Access Token
3. Docker credentials (if using container builds)

## Contributing
Feel free to contribute by submitting pull requests or creating issues for bug reports and feature requests.

## License
This project is licensed under the MIT License - see the LICENSE file for details.