#!/bin/bash
set -euo pipefail

# Script to validate chart version follows semantic versioning
# and is greater than the previous version

CHART_DIR="./charts/kubebrowse"
CHART_VERSION=$(helm show chart $CHART_DIR | grep '^version:' | awk '{print $2}')
echo "Current chart version: $CHART_VERSION"

# Validate semantic versioning format
if ! [[ $CHART_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
    echo "❌ Error: Chart version '$CHART_VERSION' does not follow semantic versioning (x.y.z or x.y.z-prerelease)"
    exit 1
fi

# Get the latest tag from git
LATEST_TAG=$(git tag --sort=-version:refname | grep '^v' | head -n1 || echo "v0.0.0")
LATEST_VERSION=${LATEST_TAG#v}

echo "Latest released version: $LATEST_VERSION"

# Compare versions using sort -V (version sort)
if [[ "$LATEST_VERSION" != "0.0.0" ]]; then
    HIGHER_VERSION=$(printf '%s\n%s' "$LATEST_VERSION" "$CHART_VERSION" | sort -V | tail -n1)
    
    if [[ "$HIGHER_VERSION" == "$LATEST_VERSION" ]]; then
        echo "❌ Error: Chart version '$CHART_VERSION' is not greater than latest version '$LATEST_VERSION'"
        echo "Please increment the version in Chart.yaml"
        exit 1
    fi
fi

echo "✅ Chart version validation passed"
echo "Version $CHART_VERSION is valid and greater than $LATEST_VERSION"