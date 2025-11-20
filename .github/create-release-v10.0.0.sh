#!/bin/bash
# Script to create GitHub release v10.0.0
# This script documents the steps needed to create the release
# Run this script after merging the PR to create the release

set -e

REPO_OWNER="baoduy"
REPO_NAME="ShareWorkflows"
TAG_NAME="v10.0.0"
RELEASE_NAME="Release v10.0.0"
RELEASE_NOTES_FILE=".github/release-notes-v10.0.0.md"

echo "=========================================="
echo "Creating GitHub Release v10.0.0"
echo "=========================================="
echo ""

# Check if gh is authenticated
if ! gh auth status &>/dev/null; then
    echo "Error: GitHub CLI (gh) is not authenticated."
    echo "Please run: gh auth login"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "$RELEASE_NOTES_FILE" ]; then
    echo "Error: Release notes file not found: $RELEASE_NOTES_FILE"
    echo "Please run this script from the repository root."
    exit 1
fi

echo "Step 1: Pushing tag $TAG_NAME to remote..."
git push origin $TAG_NAME || echo "Tag might already exist on remote, continuing..."

echo ""
echo "Step 2: Creating GitHub release..."
if [ -f "$RELEASE_NOTES_FILE" ]; then
    gh release create $TAG_NAME \
        --title "$RELEASE_NAME" \
        --notes-file "$RELEASE_NOTES_FILE" \
        --repo "$REPO_OWNER/$REPO_NAME"
else
    gh release create $TAG_NAME \
        --title "$RELEASE_NAME" \
        --generate-notes \
        --repo "$REPO_OWNER/$REPO_NAME"
fi

echo ""
echo "=========================================="
echo "Release created successfully!"
echo "View at: https://github.com/$REPO_OWNER/$REPO_NAME/releases/tag/$TAG_NAME"
echo "=========================================="
