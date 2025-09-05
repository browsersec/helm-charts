#!/bin/bash
set -euo pipefail

# Script to test the Helm chart locally before releasing

CHART_DIR="./charts/kubebrowse"

echo "🧪 Testing KubeBrowse Helm Chart"
echo "================================"

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ Error: Helm is not installed"
    echo "Please install Helm: https://helm.sh/docs/intro/install/"
    exit 1
fi

echo "✅ Helm is installed: $(helm version --short)"

# Lint the chart
echo ""
echo "🔍 Linting chart..."
if helm lint $CHART_DIR; then
    echo "✅ Chart linting passed"
else
    echo "❌ Chart linting failed"
    exit 1
fi

# Validate chart templates
echo ""
echo "📝 Validating chart templates..."
if helm template kubebrowse-test $CHART_DIR --namespace kubebrowse-test-ns --set namespace=kubebrowse-test-ns > /dev/null; then
    echo "✅ Chart template validation passed"
else
    echo "❌ Chart template validation failed"
    exit 1
fi

# Test chart installation with dry-run
echo ""
echo "🚀 Testing chart installation (dry-run)..."
if helm install kubebrowse-test $CHART_DIR --dry-run --namespace kubebrowse-test-ns --create-namespace --set namespace=kubebrowse-test-ns > /dev/null; then
    echo "✅ Chart installation test passed"
else
    echo "❌ Chart installation test failed"
    exit 1
fi

# Validate version format
echo ""
echo "🏷️  Validating version format..."
if ./scripts/validate-version.sh; then
    echo "✅ Version validation passed"
else
    echo "❌ Version validation failed"
    exit 1
fi

# Check for required files
echo ""
echo "📁 Checking required files..."
REQUIRED_FILES=(
    "$CHART_DIR/Chart.yaml"
    "$CHART_DIR/values.yaml" 
    "$CHART_DIR/templates/namespace.yaml"
    "$CHART_DIR/templates/postgres.yaml"
    "$CHART_DIR/templates/redis.yaml"
    "$CHART_DIR/templates/minio.yaml"
    "$CHART_DIR/templates/guacd.yaml"
    "$CHART_DIR/templates/api.yaml"
    "$CHART_DIR/templates/frontend.yaml"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file"
    else
        echo "❌ Missing: $file"
        exit 1
    fi
done

echo ""
echo "🎉 All tests passed! Chart is ready for release."
echo ""
echo "📦 Chart Info:"
helm show chart $CHART_DIR | grep -E "^(name|version|appVersion|description):"

echo ""
echo "🚀 To release this version:"
echo "  1. Commit and push changes to main branch"
echo "  2. The release workflow will automatically create a release"
echo "  3. Chart will be available at: https://browsersec.github.io/helm-charts"