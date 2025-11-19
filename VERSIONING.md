# Versioning Strategy

This document describes the versioning strategy used in the ShareWorkflows repository.

## Current Implementation

We use the `paulhatch/semantic-version@v5.4.0` GitHub Action to automatically calculate semantic versions based on git tags.

### How It Works

1. **Version Detection**: The action scans existing git tags to find the latest version
2. **Version Increment**: By default, it increments the patch version (e.g., 1.2.3 → 1.2.4)
3. **Manual Control**: You can control version bumps through commit messages

### Controlling Version Bumps

To manually control which version component gets incremented, include specific keywords in your commit messages:

- **Patch version** (default): `1.2.3 → 1.2.4`
  - No special keyword needed
  - Used for bug fixes and minor changes

- **Minor version**: `1.2.3 → 1.3.0`
  - Include `(MINOR)` in your commit message
  - Used for new features that are backward compatible

- **Major version**: `1.2.3 → 2.0.0`
  - Include `(MAJOR)` in your commit message
  - Used for breaking changes

### Examples

```bash
# Patch version bump (default)
git commit -m "Fix: resolve issue with npm publishing"

# Minor version bump
git commit -m "Feature: add support for custom build args (MINOR)"

# Major version bump
git commit -m "Breaking: change workflow input parameter names (MAJOR)"
```

## Configuration

The version calculation is configured in the workflow files with the following parameters:

```yaml
- name: Calculate version
  id: version
  uses: paulhatch/semantic-version@v5.4.0
  with:
    tag_prefix: "v"
    major_pattern: "(MAJOR)"
    minor_pattern: "(MINOR)"
    version_format: "${major}.${minor}.${patch}"
    bump_each_commit: false
    search_commit_body: false
```

### Parameters Explained

- `tag_prefix`: The prefix for version tags (e.g., "v" for v1.2.3)
- `major_pattern`: Regex pattern to match for major version bumps
- `minor_pattern`: Regex pattern to match for minor version bumps
- `version_format`: Format string for the version output
- `bump_each_commit`: Whether to bump version for every commit (disabled)
- `search_commit_body`: Whether to search in commit body for patterns (disabled)

## Migration from git-next-version

Previously, this repository used `rmeneely/git-next-version@v1`, which had limitations:
- Could not handle double-digit version numbers (e.g., v10.0.0)
- Less flexible version control

The new implementation:
- ✅ Handles all version numbers correctly (including v10.0.0 and beyond)
- ✅ More actively maintained
- ✅ Better control over version bumps
- ✅ Maintains backward compatibility

## Outputs

The version step provides the following outputs:

- `version`: The calculated version without prefix (e.g., "1.2.3")
- `version_tag`: The full version tag with prefix (e.g., "v1.2.3")
- `major`: Major version number
- `minor`: Minor version number
- `patch`: Patch version number

These outputs are used throughout the workflow:

```yaml
# Set environment variable for backward compatibility
- name: Set NEXT_VERSION
  run: echo "NEXT_VERSION=${{ steps.version.outputs.version }}" >> $GITHUB_ENV

# Use in subsequent steps
- name: Create Release
  with:
    tag_name: v${{ env.NEXT_VERSION }}
```

## Best Practices

1. **Tag your releases**: Always create git tags for releases (e.g., `v1.2.3`)
2. **Use semantic versioning**: Follow [semver](https://semver.org/) principles
3. **Meaningful commits**: Use clear commit messages with version control keywords when needed
4. **Review before merge**: Always check the calculated version before merging

## Troubleshooting

### Version not incrementing
- Check that you have at least one git tag in the repository
- Verify the tag follows the format `v[major].[minor].[patch]` (e.g., v1.0.0)

### Wrong version calculated
- Review recent commit messages for (MAJOR) or (MINOR) keywords
- Check existing git tags with `git tag -l`

### Starting from scratch
If you don't have any tags yet, the action will start from `0.1.0` by default. Create your first tag:
```bash
git tag v1.0.0
git push origin v1.0.0
```
