#!/bin/bash
set -euo pipefail

# Script to release a new version of the Helm chart

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 0.2.0"
    exit 1
fi

NEW_VERSION="$1"
CHART_FILE="Chart.yaml"

# Validate version format
if ! [[ $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
    echo "❌ Error: Version '$NEW_VERSION' does not follow semantic versioning (x.y.z or x.y.z-prerelease)"
    exit 1
fi

echo "🚀 Preparing release for version $NEW_VERSION"
echo "=============================================="

# Check if we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "main" ]]; then
    echo "❌ Error: Must be on main branch to release (currently on: $CURRENT_BRANCH)"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "❌ Error: You have uncommitted changes. Please commit or stash them first."
    exit 1
fi

# Get current version
CURRENT_VERSION=$(grep '^version:' $CHART_FILE | awk '{print $2}')
echo "Current version: $CURRENT_VERSION"
echo "New version: $NEW_VERSION"

# Update Chart.yaml version
echo ""
echo "📝 Updating Chart.yaml..."
sed -i "s/^version: .*/version: $NEW_VERSION/" $CHART_FILE

# Verify the change
NEW_VERSION_CHECK=$(grep '^version:' $CHART_FILE | awk '{print $2}')
if [[ "$NEW_VERSION_CHECK" != "$NEW_VERSION" ]]; then
    echo "❌ Error: Failed to update version in Chart.yaml"
    exit 1
fi

echo "✅ Updated version in Chart.yaml: $CURRENT_VERSION → $NEW_VERSION"

# Run tests
echo ""
echo "🧪 Running tests..."
if ./scripts/test.sh; then
    echo "✅ All tests passed"
else
    echo "❌ Tests failed. Rolling back version change."
    sed -i "s/^version: .*/version: $CURRENT_VERSION/" $CHART_FILE
    exit 1
fi

# Commit the version change
echo ""
echo "📝 Committing version change..."
git add $CHART_FILE
git commit -m "Bump chart version to $NEW_VERSION"

echo ""
echo "🎉 Version $NEW_VERSION is ready for release!"
echo ""
echo "Next steps:"
echo "  1. Push to main branch: git push origin main"
echo "  2. The GitHub Actions workflow will automatically:"
echo "     • Create a GitHub release"
echo "     • Publish to GitHub Pages"
echo "     • Create a git tag v$NEW_VERSION"
echo "     • Trigger OCI registry publishing"
echo ""
echo "📦 Once published, the chart will be available at:"
echo "  • GitHub Pages: https://browsersec.github.io/helm-charts"
echo "  • OCI Registry: oci://ghcr.io/browsersec/charts/kubebrowse"
echo ""
echo "🔍 Chart will be automatically indexed by Artifact Hub"

# Ask for confirmation to push
read -p "Push to main branch now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Pushing to main branch..."
    git push origin main
    echo "✅ Pushed! Check GitHub Actions for the release process."
    echo "🔗 GitHub Actions: https://github.com/browsersec/helm-charts/actions"
else
    echo "📝 Changes committed locally. Push when ready with: git push origin main"
fi