#!/bin/bash
#
# This script automates the process of redeploying a specific service
# using the 'minikube docker-env' method for faster builds.
# It builds the Docker image directly inside Minikube and restarts the deployment.
#
# Usage: ./redeploy-service.sh <service-name>
# Example: ./redeploy-service.sh frontend

# Exit immediately if a command exits with a non-zero status.
set -e

# 1. Check for service name argument
SERVICE_NAME=$1
if [ -z "$SERVICE_NAME" ]; then
    echo "❌ Error: Service name not provided."
    echo "Usage: $0 <service-name>"
    echo "Example: $0 frontend"
    exit 1
fi

echo "🚀 Starting redeployment for service: $SERVICE_NAME"

echo "🔵 1. Pointing Docker CLI to Minikube's Docker daemon..."
eval $(minikube docker-env)
echo "✅ Docker environment set for Minikube."

echo "🔵 2. Rebuilding '$SERVICE_NAME:local' image..."
docker build --no-cache -t "${SERVICE_NAME}:local" "src/${SERVICE_NAME}"
echo "✅ Image rebuilt successfully."

echo "🔵 3. Restarting '$SERVICE_NAME' deployment..."
kubectl rollout restart "deployment/${SERVICE_NAME}"
echo "✅ Rollout initiated."

echo "🔵 4. Waiting for deployment to complete..."
kubectl rollout status "deployment/${SERVICE_NAME}"

echo "🔵 5. Reverting Docker environment back to local host..."
eval $(minikube docker-env -u)

echo "🎉 Service '$SERVICE_NAME' has been successfully redeployed!"