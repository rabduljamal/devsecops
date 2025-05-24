# DevSecOps Pipeline - GitHub Actions Setup

## 🚀 Quick Setup Guide

### 1. Repository Structure
```
your-repo/
├── .github/workflows/
│   └── ci-cd.yml
├── k8s/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── hpa.yaml
│   └── network-policy.yaml
├── Dockerfile
├── nginx.conf
├── index.html
└── README.md
```

### 2. Required GitHub Secrets

Masuk ke **Settings > Secrets and variables > Actions** dan tambahkan:

#### Basic Secrets:
- `GITHUB_TOKEN` (automatically provided)

#### GitOps Integration:
- `GITOPS_TOKEN`: Personal Access Token untuk GitOps repository
- `GITOPS_REPO`: Format `username/gitops-repo-name`

#### ArgoCD Integration (Optional):
- `ARGOCD_WEBHOOK_URL`: ArgoCD webhook URL
- `ARGOCD_TOKEN`: ArgoCD API token

#### DefectDojo Integration (Optional):
- `DEFECTDOJO_URL`: DefectDojo instance URL
- `DEFECTDOJO_API_KEY`: API key untuk DefectDojo

### 3. Enable GitHub Container Registry

1. Go to **Settings > Developer settings > Personal access tokens**
2. Create token dengan scope: `write:packages`, `read:packages`
3. Login ke GHCR:
```bash
echo $PAT | docker login ghcr.io -u USERNAME --password-stdin
```

### 4. Workflow Features

#### Security Scanning:
- ✅ **Gitleaks**: Secret detection
- ✅ **Trivy**: Filesystem & container scanning
- ✅ **SARIF**: Upload hasil scan ke GitHub Security tab
- ✅ **SBOM**: Software Bill of Materials generation

#### Build & Push:
- ✅ **Multi-platform**: linux/amd64, linux/arm64
- ✅ **Cache optimization**: GitHub Actions cache
- ✅ **Metadata**: Semantic versioning
- ✅ **Provenance**: Supply chain security

#### GitOps Integration:
- ✅ **Webhook trigger**: Automatic GitOps repo update
- ✅ **Image update**: Update Kubernetes manifests
- ✅ **ArgoCD sync**: Automatic deployment trigger

### 5. Container Registry URLs

Setelah workflow berjalan, image akan tersedia di:
```
ghcr.io/username/repository:latest
ghcr.io/username/repository:main
ghcr.io/username/repository:sha-1234567
ghcr.io/username/repository:v1.0.0
```

### 6. GitOps Repository Setup

Buat repository terpisah untuk GitOps dengan struktur:
```
gitops-repo/
├── .github/workflows/
│   └── gitops-update.yml
├── k8s/
│   └── (manifests dari file k8s di atas)
├── helm/ (optional)
└── argocd/ (optional)
```

### 7. ArgoCD Application Example

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: devsecops-pipeline
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/username/gitops-repo
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: devsecops-pipeline
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

### 8. Monitoring & Observability

#### DefectDojo Integration:
```bash
# Kirim hasil scan ke DefectDojo
curl -X POST \
  -H "Authorization: Token $DEFECTDOJO_API_KEY" \
  -F "scan_type=Trivy Scan" \
  -F "file=@trivy-results.json" \
  "$DEFECTDOJO_URL/api/v2/import-scan/"
```

#### Wazuh XDR Integration:
- Monitor aplikasi yang running di Kubernetes
- Collect logs dari nginx container
- Alert pada security events

### 9. Testing the Pipeline

1. **Push ke branch main**:
```bash
git add .
git commit -m "feat: update devsecops pipeline"
git push origin main
```

2. **Create release tag**:
```bash
git tag v1.0.0
git push origin v1.0.0
```

3. **Monitor workflow**:
   - Go to **Actions** tab
   - Check workflow progress
   - View security scan results in **Security** tab

### 10. Vault Integration

Untuk secret management dengan Vault:

```yaml
# Tambah di deployment.yaml
spec:
  template:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "devsecops-pipeline"
        vault.hashicorp.com/agent-inject-secret-config: "secret/devsecops"
```

### 11. Troubleshooting

#### Common Issues:
- **Permission denied**: Check GITHUB_TOKEN permissions
- **Image not found**: Verify repository name dan visibility
- **Workflow fails**: Check secrets dan repository settings
- **GitOps not triggered**: Verify GITOPS_TOKEN dan repository dispatch

#### Debug Commands:
```bash
# Check image
docker pull ghcr.io/username/repo:latest

# Verify Kubernetes deployment
kubectl get pods -n devsecops-pipeline
kubectl logs -f deployment/devsecops-pipeline -n devsecops-pipeline

# Check ArgoCD sync
argocd app sync devsecops-pipeline
```

## 🎯 Next Steps

1. Setup monitoring dengan Prometheus & Grafana
2. Configure Wazuh agents untuk security monitoring
3. Implement policy-as-code dengan OPA Gatekeeper
4. Add performance testing dengan k6
5. Setup chaos engineering dengan Chaos Mesh

Happy DevSecOps! 🚀🔒