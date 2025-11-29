# Practica-2-Kube

This repository contains two Kubernetes exercises demonstrating different deployment approaches.

---

## Ejercicio 1: Drupal + MySQL with YAML Manifests

Deployment of a Drupal CMS with MySQL database using traditional Kubernetes YAML manifests.

### Architecture

```
┌─────────────────┐     ┌─────────────────┐
│     Drupal      │────▶│      MySQL      │
│   (NodePort)    │     │   (ClusterIP)   │
│    Port 30085   │     │    Port 3306    │
└────────┬────────┘     └────────┬────────┘
         │                       │
    ┌────▼────┐             ┌────▼────┐
    │drupal-pvc│             │mysql-pvc │
    │   1Gi   │             │   1Gi    │
    └─────────┘             └──────────┘
```

### Files Structure

| File | Description |
|------|-------------|
| `drupal-deploy.yaml` | Drupal Deployment with init container |
| `drupal-service.yaml` | NodePort Service (port 30085) |
| `drupal-pvc.yaml` | PersistentVolumeClaim (1Gi) |
| `mysql-deploy.yaml` | MySQL Deployment |
| `mysql-service.yaml` | ClusterIP Service (port 3306) |
| `mysql-pvc.yaml` | PersistentVolumeClaim (1Gi) |

### Configuration Details

#### Drupal
- **Image**: `drupal:latest`
- **Port**: 80 (exposed via NodePort 30085)
- **Init Container**: Copies initial `/var/www/html/sites/` to persistent storage
- **Volume Mount**: `/var/www/html/sites`

#### MySQL
- **Image**: `mysql:latest`
- **Port**: 3306 (internal ClusterIP)
- **Volume Mount**: `/var/lib/mysql`
- **Environment Variables**:
  - `MYSQL_ROOT_PASSWORD`: rootpass
  - `MYSQL_DATABASE`: drupaldb
  - `MYSQL_USER`: drupaluser
  - `MYSQL_PASSWORD`: drupalpass

### Deployment

```bash
# Apply all manifests
kubectl apply -f ./ejercicio-1

# Check status
kubectl get svc,deploy,pod,pvc

# Access Drupal
# Via NodePort: http://localhost:30085
# Or use port-forward: kubectl port-forward svc/service-drupal 8085:80
```

### Drupal Database Configuration

When installing Drupal, use these database settings:
- **Database name**: drupaldb
- **Database username**: drupaluser
- **Database password**: drupalpass
- **Host**: service-mysql
- **Port**: 3306

---

## Ejercicio 2: Matomo + MariaDB with Terraform

Deployment of Matomo analytics platform with MariaDB using Terraform for infrastructure as code.

### Architecture

```
┌─────────────────┐     ┌─────────────────┐
│     Matomo      │────▶│     MariaDB     │
│   (NodePort)    │     │   (ClusterIP)   │
│    Port 30085   │     │    Port 3306    │
└────────┬────────┘     └────────┬────────┘
         │                       │
    ┌────▼────┐             ┌────▼─────┐
    │matomo-pvc│             │mariadb-pvc│
    │   1Gi   │             │   1Gi     │
    └─────────┘             └───────────┘
```

### Files Structure

| File | Description |
|------|-------------|
| `main.tf` | Terraform provider configuration |
| `matomo.tf` | Matomo Deployment and Service |
| `mariadb.tf` | MariaDB Deployment and Service |
| `matomo-pvc.yaml` | Matomo PersistentVolumeClaim |
| `mariadb-pvc.yaml` | MariaDB PersistentVolumeClaim |
| `matomo.Dockerfile` | Custom Matomo image with PHP configs |
| `cluster-config/cluster-config.yaml` | Kind cluster configuration |

### Custom Dockerfile

The `matomo.Dockerfile` includes custom PHP configurations:
- **PHP Memory Limit**: 512M
- **Upload Max Filesize**: 512M
- **Post Max Size**: 512M

Configuration file created at: `/usr/local/etc/php/conf.d/zzz-matomo.ini`

### Configuration Details

#### Matomo
- **Image**: `matomo:latest` (or custom built image)
- **Port**: 80 (exposed via NodePort 30085 → hostPort 8081)
- **Volume Mount**: `/var/www/html`

#### MariaDB
- **Image**: `bitnami/mariadb:latest`
- **Port**: 3306 (internal ClusterIP)
- **Volume Mount**: `/bitnami/mariadb`
- **Environment Variables**:
  - `ALLOW_EMPTY_PASSWORD`: yes
  - `MARIADB_USER`: matomo_user
  - `MARIADB_DATABASE`: matomo_db

### Deployment

```bash
cd ejercicio-2

# Create Kind cluster with port mapping
kind create cluster --config cluster-config/cluster-config.yaml

# Apply PVCs first
kubectl apply -f matomo-pvc.yaml
kubectl apply -f mariadb-pvc.yaml

# Initialize and apply Terraform
terraform init
terraform apply

# Check status
kubectl get svc,deploy,pod,pvc

# Access Matomo at http://localhost:8081
```

### Matomo Database Configuration

When installing Matomo, use these database settings:
- **Database server**: mariadb-service
- **Login**: matomo_user
- **Password**: (empty)
- **Database name**: matomo_db

---

## GitHub Actions CI/CD

### Matomo Docker Image Workflow

Located at `.github/workflows/matomo-wf.yaml`

**Trigger**: Push to `main` branch

**Actions**:
1. Checkout repository
2. Login to Docker Hub
3. Build custom Matomo image from `ejercicio-2/matomo.Dockerfile`
4. Push to Docker Hub as `<username>/matomo-custom:latest`

**Required Secrets**:
- `DOCKERHUB_USERNAME`: Docker Hub username
- `DOCKERHUB_TOKEN`: Docker Hub access token

---

## Prerequisites

- Kubernetes cluster (Kind, Minikube, etc.)
- kubectl configured
- Terraform (for ejercicio-2)
- Docker (for building custom images)
