# Bank of Anthos - Local Deployment Guide

This document explains how to build and deploy the Bank of Anthos application locally without any Google Cloud dependencies.

## Prerequisites

- Docker
- Kubernetes cluster (Minikube)
- kubectl
- Maven (for Java services)
- Python 3.12+ (for Python services)

## Cleanup Previous Deployment

If you have a previous deployment, clean it up:
```bash
# Delete all pods
kubectl delete pods --all

# Stop and delete Minikube cluster
minikube stop
minikube delete

# Remove Docker images
docker rmi -f $(docker images -aq)

# Prune Docker build cache
docker builder prune -a
```

## Start Fresh Environment

1. Start Minikube:
```bash
minikube start
```

## Build Docker Images

### Python Services

Build the Python-based services:
```bash
# Frontend service
cd src/frontend && docker build -t frontend:local .

# User service
cd src/accounts/userservice && docker build -t userservice:local .

# Contacts service
cd src/accounts/contacts && docker build -t contacts:local .

# Account database
cd src/accounts/accounts-db && docker build -t accounts-db:local .

# Ledger database
cd src/ledger/ledger-db && docker build -t ledger-db:local .

# Load generator
cd src/loadgenerator && docker build -t loadgenerator:local .
```

### Java Services

Build the Java-based services using Maven Jib plugin:
```bash
# Balance reader service
cd src/ledger/balancereader && mvn compile jib:dockerBuild -Djib.to.image=balancereader:local

# Ledger writer service
cd src/ledger/ledgerwriter && mvn compile jib:dockerBuild -Djib.to.image=ledgerwriter:local

# Transaction history service
cd src/ledger/transactionhistory && mvn compile jib:dockerBuild -Djib.to.image=transactionhistory:local
```

## Load Images into Minikube

Load all built images into Minikube's Docker environment:
```bash
minikube image load accounts-db:local
minikube image load balancereader:local
minikube image load contacts:local
minikube image load frontend:local
minikube image load ledger-db:local
minikube image load ledgerwriter:local
minikube image load loadgenerator:local
minikube image load transactionhistory:local
minikube image load userservice:local
```

## Deploy to Kubernetes

Apply the Kubernetes manifests:
```bash
# Apply JWT secret
kubectl apply -f extras/jwt/jwt-secret.yaml

# Apply all service manifests
kubectl apply -f kubernetes-manifests
```

## Verify Deployment

Check that all pods are running:
```bash
kubectl get pods
```

All pods should show "1/1" in the READY column and "Running" in the STATUS column.

## Access the Application

Get the URL for the frontend service:
```bash
minikube service frontend --url
```

This will return a URL like `http://192.168.49.2:30664` where you can access the application.

## Key Differences from Cloud Deployment

1. **No Google Cloud dependencies**: All services run locally without Google Cloud APIs
2. **Local Docker images**: Images are tagged with `:local` instead of pulling from Google Container Registry
3. **In-cluster databases**: PostgreSQL databases run as StatefulSets instead of using Google Cloud SQL
4. **Disabled tracing/metrics**: Google Cloud tracing and monitoring are disabled
5. **Local JWT secret**: Authentication uses a locally generated JWT secret

## Services Overview

1. **Frontend**: Web interface (Python/Flask)
2. **User Service**: Account management and authentication (Python/Flask)
3. **Contacts Service**: Contact list management (Python/Flask)
4. **Account Database**: User account data (PostgreSQL)
5. **Ledger Writer**: Transaction processing (Java/Spring Boot)
6. **Balance Reader**: Account balance queries (Java/Spring Boot)
7. **Transaction History**: Transaction history queries (Java/Spring Boot)
8. **Ledger Database**: Financial transaction data (PostgreSQL)
9. **Load Generator**: Simulates user traffic (Python/Locust)

## Troubleshooting

If pods are not starting:
1. Check image names in Kubernetes manifests match the built images
2. Verify images are loaded into Minikube: `minikube image ls`
3. Check pod logs: `kubectl logs <pod-name>`
4. Ensure JWT secret is applied: `kubectl get secrets`