#!/bin/bash

# AirName Release Script
# Creates a git tag to trigger automated GitHub release

set -e

echo "🚀 AirName Release Helper"
echo ""

# Get current version from build script or generate timestamp version
if [ -f "build.sh" ]; then
    VERSION=$(date "+%Y.%m.%d.%H%M")
    echo "Generated version: $VERSION"
else
    echo "build.sh not found. Using manual version."
    read -p "Enter version (e.g. 2025.09.27.1543): " VERSION
fi

echo ""
echo "Creating release for version: $VERSION"
echo ""

# Verify we're on main branch and up to date
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "⚠️  Warning: You're on branch '$CURRENT_BRANCH', not 'main'"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Release cancelled."
        exit 1
    fi
fi

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  Warning: You have uncommitted changes:"
    git status --short
    echo ""
    read -p "Commit changes and continue with release? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add -A
        git commit -m "Prepare release v$VERSION"
        git push origin $CURRENT_BRANCH
    else
        echo "Please commit your changes first, then run this script again."
        exit 1
    fi
fi

# Create and push tag
TAG="v$VERSION"
echo "Creating tag: $TAG"

if git tag -l | grep -q "^$TAG$"; then
    echo "❌ Tag $TAG already exists!"
    echo "Existing tags:"
    git tag -l | tail -5
    exit 1
fi

# Create annotated tag with message
git tag -a "$TAG" -m "Release version $VERSION"

echo "Pushing tag to GitHub..."
git push origin "$TAG"

echo ""
echo "✅ Release triggered!"
echo "📦 Tag: $TAG"
echo "🔗 GitHub will automatically:"
echo "   • Build the release"
echo "   • Create release notes"
echo "   • Attach unsigned app bundle"
echo ""
echo "Visit: https://github.com/rodchristiansen/airname/releases"
echo ""
echo "⚠️  Note: GitHub release contains unsigned build for testing only."
echo "For production deployment, use local './build.sh' with signing credentials."