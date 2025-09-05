# Helm Chart Publishing Workflows

This directory contains GitHub Actions workflows for publishing the KubeBrowse Helm chart.

## Workflows

### 1. `release.yml` - GitHub Pages Publishing

**Trigger**: Push to `main` branch with changes to chart files
**Purpose**: Publishes chart to GitHub Pages (https://browsersec.github.io/helm-charts)

**What it does**:
- Lints and validates the chart
- Packages the chart
- Creates GitHub releases when version changes
- Updates GitHub Pages with Helm repository index
- Users can install with: `helm repo add browsersec https://browsersec.github.io/helm-charts`

### 2. `oci-publish.yml` - OCI Registry Publishing

**Trigger**: Push tags matching `v*` (e.g., v0.1.0)
**Purpose**: Publishes chart to GitHub Container Registry (OCI format)

**What it does**:
- Lints and validates the chart
- Packages and pushes to `ghcr.io/browsersec/charts`
- Users can install with: `helm install kubebrowse oci://ghcr.io/browsersec/charts/kubebrowse`

## Prerequisites

### GitHub Repository Settings

1. **Enable GitHub Pages**:
   - Go to Settings → Pages
   - Set Source to "GitHub Actions"

2. **Enable GitHub Container Registry**:
   - Go to Settings → Actions → General
   - Under "Workflow permissions", select "Read and write permissions"

### Required Permissions

The workflows need these permissions (already configured):
- `contents: write` - To create releases and tags
- `pages: write` - To publish GitHub Pages
- `packages: write` - To publish to GHCR
- `id-token: write` - For OIDC authentication

## Publishing Process

### Method 1: GitHub Pages (Automatic)

1. **Update chart version** in `Chart.yaml`:
   ```yaml
   version: 0.2.0  # Increment this
   ```

2. **Commit and push**:
   ```bash
   git add Chart.yaml
   git commit -m "Bump chart version to 0.2.0"
   git push origin main
   ```

3. **Automatic publishing**:
   - Workflow creates GitHub release
   - Updates GitHub Pages repository
   - Chart becomes available at: https://browsersec.github.io/helm-charts

### Method 2: OCI Registry (Tag-based)

1. **Create and push a tag**:
   ```bash
   git tag v0.2.0
   git push origin v0.2.0
   ```

2. **Automatic publishing**:
   - Workflow publishes to GHCR
   - Chart becomes available at: `oci://ghcr.io/browsersec/charts/kubebrowse`

### Using Helper Scripts

Use the provided scripts in the `scripts/` directory:

```bash
# Test the chart locally
./scripts/test.sh

# Release a new version
./scripts/release.sh 0.2.0
```

## Installation Instructions for Users

### From GitHub Pages
```bash
helm repo add browsersec https://browsersec.github.io/helm-charts
helm repo update
helm install kubebrowse browsersec/kubebrowse
```

### From OCI Registry
```bash
helm install kubebrowse oci://ghcr.io/browsersec/charts/kubebrowse --version 0.1.0
```

## Troubleshooting

### Common Issues

1. **"No artifacts named github-pages"**: 
   - Fixed in current workflow - chart-releaser handles GitHub Pages automatically

2. **Permission denied**:
   - Check repository settings for workflow permissions
   - Ensure GitHub Pages is enabled

3. **Chart validation fails**:
   - Run `helm lint .` locally to check for issues
   - Use `./scripts/test.sh` for comprehensive validation

### Debugging

- Check workflow runs in GitHub Actions tab
- View logs for detailed error messages
- Test locally with helper scripts before pushing

## Workflow Features

✅ **Chart linting and validation**
✅ **Automatic versioning and tagging**
✅ **GitHub Pages publishing**
✅ **OCI registry publishing**
✅ **Proper permissions and security**
✅ **Helper scripts for local testing**