# SacuNXT Connector Framework - Kubernetes Deployment

A comprehensive Helm chart for deploying the SacuNXT Connector Framework microservices on any Kubernetes cluster. This cloud-agnostic solution provides enterprise-grade deployment capabilities with support for multiple container registries and cloud providers.

## 🏗️ Architecture

The SacuNXT Connector Framework consists of the following microservices:

### Core Services
- **API Service** (Port 8000) - Main REST API endpoint
- **Scheduler Service** (Port 8002) - Task scheduling and orchestration
- **Config Service** (Port 8080) - Configuration management
- **Collector Service** (Port 8080) - Data collection
- **Normalizer Service** (Port 8080) - Data normalization
- **Publisher Service** (Port 8080) - Data publishing
- **Action Service** (Port 8080) - Action execution

### Infrastructure Components
- **PostgreSQL** - Primary database (Port 5432)
- **Redis** - Caching and session storage (Port 6379)
- **Apache Kafka** - Message streaming (Port 9092)
- **Zookeeper** - Kafka coordination (Port 2181)

## 📁 Project Structure

```
├── helm/
│   └── sacunxt/
│       ├── Chart.yaml              # Helm chart metadata
│       ├── values.yaml             # Default configuration values
│       └── templates/
│           ├── _helpers.tpl        # Template helpers
│           ├── microservices.yaml  # All microservice deployments
│           ├── postgresql.yaml     # PostgreSQL deployment
│           ├── redis.yaml          # Redis deployment
│           └── kafka.yaml          # Kafka and Zookeeper deployment
└── examples/
    └── values.yaml.example         # Example configuration file
```

## 🚀 Quick Start

### Prerequisites

- Kubernetes cluster (1.20+)
- Helm 3.x
- kubectl configured for your cluster
- Container registry access (Docker Hub, ECR, ACR, GCR, etc.)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd SacuNXT-Azure-AKS-Complete-Deployment
   ```

2. **Add Bitnami Helm repository** (for dependencies)
   ```bash
   helm repo add bitnami https://charts.bitnami.com/bitnami
   helm repo update
   ```

3. **Configure your values**
   ```bash
   cp examples/values.yaml.example my-values.yaml
   # Edit my-values.yaml with your specific configuration
   ```

4. **Install the chart**
   ```bash
   helm install sacunxt ./helm/sacunxt -f my-values.yaml
   ```

### Verification

Check deployment status:
```bash
kubectl get pods
kubectl get services
```

## ⚙️ Configuration

### Container Registry Setup

The chart supports multiple container registries. Update the `global.imageRegistry` in your values file:

**Docker Hub:**
```yaml
global:
  imageRegistry: "docker.io"
```

**AWS ECR:**
```yaml
global:
  imageRegistry: "123456789.dkr.ecr.region.amazonaws.com"
  createECRSecret: true
```

**Azure ACR:**
```yaml
global:
  imageRegistry: "myregistry.azurecr.io"
```

**Google GCR:**
```yaml
global:
  imageRegistry: "gcr.io/project-id"
```

### Database Configuration

PostgreSQL is deployed by default with the following settings:
```yaml
postgresql:
  enabled: true
  auth:
    username: "sacunxt"
    password: "sacunxt_password"
    database: "api_service"
```

### Resource Management

Configure resource requests and limits for each service:
```yaml
apiService:
  resources:
    requests:
      memory: "256Mi"
      cpu: "200m"
    limits:
      memory: "512Mi"
      cpu: "500m"
```

### Environment-Specific Configurations

The chart supports multiple environments:
- **Development** - Minimal resources, single replicas
- **Staging** - Moderate resources, 2 replicas
- **Production** - Full resources, 3+ replicas

## 🔧 Customization

### Service Ports

All service ports are configurable:
```yaml
apiService:
  service:
    port: 8000
    targetPort: 8000

schedulerService:
  service:
    port: 8002
    targetPort: 8002
```


### Persistent Storage

Configure storage for databases:
```yaml
postgresql:
  primary:
    persistence:
      enabled: true
      storageClass: "gp2"  # AWS
      # storageClass: "managed-premium"  # Azure
      # storageClass: "ssd"  # GCP
      size: 10Gi
```

## 🔐 Security

### Image Pull Secrets

For private registries, configure image pull secrets:
```yaml
imageCredentials:
  registry: "your-registry.com"
  username: "your-username"
  password: "your-password"
  email: "admin@example.com"
```

### Network Policies

Enable network policies for enhanced security:
```yaml
networkPolicy:
  enabled: true
  ingress:
    enabled: true
  egress:
    enabled: true
```

## 📊 Monitoring & Observability

### Health Checks

All services include health checks:
- **Liveness Probe** - Restarts unhealthy containers
- **Readiness Probe** - Controls traffic routing

### Metrics Collection

Enable Prometheus metrics:
```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
```

### Logging

Configure centralized logging:
```yaml
logging:
  enabled: true
  level: INFO
  format: json
```

## 🔄 Scaling

### Horizontal Pod Autoscaling

Enable HPA for automatic scaling:
```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

### Manual Scaling

Scale services manually:
```bash
kubectl scale deployment api-service --replicas=5
```

## 🛠️ Troubleshooting

### Common Issues

1. **Pod startup failures**
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

2. **Database connection issues**
   ```bash
   kubectl exec -it <api-pod> -- nc -zv postgres-service 5432
   ```

3. **Image pull errors**
   ```bash
   kubectl get events --sort-by=.metadata.creationTimestamp
   ```

### Debug Mode

Enable debug logging:
```yaml
global:
  debug: true
logging:
  level: DEBUG
```

## 🔧 Maintenance

### Backup

Configure automated backups:
```yaml
backup:
  enabled: true
  schedule: "0 2 * * *"
  retention: "7d"
```

### Updates

Update the deployment:
```bash
helm upgrade sacunxt ./helm/sacunxt -f my-values.yaml
```

### Rollback

Rollback to previous version:
```bash
helm rollback sacunxt 1
```

## 🌐 Multi-Cloud Support

This chart is designed to work across different cloud providers:

- **AWS EKS** - Use `gp2` storage class
- **Azure AKS** - Use `managed-premium` storage
- **Google GKE** - Use `ssd` storage
- **On-premises** - Use local storage classes

## 📚 Advanced Configuration

### Custom Resource Definitions

The chart supports custom resources for advanced configurations. See the `examples/values.yaml.example` file for comprehensive configuration options.

### Multi-tenancy

Deploy multiple instances with different namespaces:
```bash
helm install sacunxt-dev ./helm/sacunxt -f dev-values.yaml --namespace dev
helm install sacunxt-prod ./helm/sacunxt -f prod-values.yaml --namespace production
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

- **Documentation**: [Sacumen Documentation](https://docs.sacumen.com)
- **Issues**: Create an issue in this repository
- **Email**: suthan.natarajan@sacumen.com

## 📄 License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

---

**Maintained by**: Sacumen Team  
**Version**: 1.0.0  
**Last Updated**: August 2025