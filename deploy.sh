#!/bin/bash

# Concordia Documentation Deployment Script
# This script builds and deploys the documentation website

set -e  # Exit on any error

echo "🚀 Deploying Concordia Documentation..."

# Check if we're in the docs directory
if [ ! -f "mkdocs.yml" ]; then
    echo "❌ Error: mkdocs.yml not found. Please run this script from the docs/ directory."
    exit 1
fi

# Check if MkDocs is installed
if ! command -v mkdocs &> /dev/null; then
    echo "❌ Error: MkDocs is not installed. Installing..."
    pip install mkdocs mkdocs-material
fi

echo "📦 Building the documentation..."
mkdocs build

echo "✅ Build complete!"

# Check if we want to deploy to GitHub Pages
if [ "$1" = "--deploy" ] || [ "$1" = "-d" ]; then
    echo "🌐 Deploying to GitHub Pages..."
    mkdocs gh-deploy --clean
    echo "✅ Deployed to GitHub Pages!"
elif [ "$1" = "--serve" ] || [ "$1" = "-s" ]; then
    echo "🖥️  Starting development server..."
    echo "📍 Visit: http://localhost:8000"
    mkdocs serve
else
    echo "📁 Built files are in the 'site/' directory"
    echo ""
    echo "Options:"
    echo "  --deploy, -d    Deploy to GitHub Pages"
    echo "  --serve, -s     Start development server"
    echo ""
    echo "Example usage:"
    echo "  ./deploy.sh --deploy    # Deploy to GitHub Pages"
    echo "  ./deploy.sh --serve     # Start local server"
fi

echo "🎉 Done!"
