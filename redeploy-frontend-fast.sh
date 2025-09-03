#!/bin/bash
#
# This script automates the process of redeploying the frontend service
# using the 'minikube docker-env' method for faster builds.
# It builds the Docker image directly inside Minikube and restarts the deployment.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "🔵 1. Pointing Docker CLI to Minikube's Docker daemon..."
eval $(minikube docker-env)
echo "✅ Docker environment set."

echo "🔵 2. Rebuilding frontend Docker image directly inside Minikube..."
docker build --no-cache -t frontend:local src/frontend
docker build --no-cache -t userservice:local src/accounts/userservice
docker build --no-cache -t accounts-db:local src/accounts/accounts-db
echo "✅ Image rebuilt successfully."

echo "🔵 3. Restarting frontend deployment in Kubernetes..."
kubectl rollout restart deployment/frontend
kubectl rollout restart deployment/userservice
echo "✅ Rollout initiated."

echo "🔵 4. Waiting for deployment to complete..."
kubectl rollout status deployment/frontend
kubectl rollout status deployment/userservice
echo "🎉 Frontend service has been successfully redeployed!"

eval $(minikube docker-env -u)