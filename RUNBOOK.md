# Runbook - Troubleshooting Guide

## Common Issues and Solutions

### 1. Pods Not Starting

**Symptoms:**
- `kubectl get pods` shows pods in `Pending` or `CrashLoopBackOff` state

**Diagnosis:**
```bash
# Check pod status
kubectl get pods -n production

# Check pod logs
kubectl logs <pod-name> -n production

# Check pod events
kubectl describe pod <pod-name> -n production
```

**Common Causes:**
- Image pull errors: Check ACR credentials in `imagePullSecrets`
- Resource constraints: Check node capacity with `kubectl describe nodes`
- Configuration errors: Check ConfigMap and Secret references
- Database connection issues: Verify connection strings in Key Vault

**Solutions:**
1. Verify ACR secret exists: `kubectl get secret acr-secret -n production`
2. Check resource requests/limits match node capacity
3. Verify secrets are correctly referenced
4. Test database connectivity from a pod

---

### 2. Services Not Accessible

**Symptoms:**
- Frontend cannot connect to backend APIs
- 503 Service Unavailable errors

**Diagnosis:**
```bash
# Check service endpoints
kubectl get svc -n production

# Check ingress
kubectl get ingress -n production

# Test service from within cluster
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- curl http://auth-service/health
```

**Solutions:**
1. Verify Service selectors match Pod labels
2. Check Ingress controller is running: `kubectl get pods -n ingress-nginx`
3. Verify Ingress rules are correct
4. Check network policies if enabled

---

### 3. Database Connection Failures

**Symptoms:**
- Application logs show connection timeout or authentication errors
- Pods restarting frequently

**Diagnosis:**
```bash
# Check application logs
kubectl logs -l app=auth-service -n production --tail=100

# Verify secrets
kubectl get secret auth-secrets -n production -o yaml
```

**Solutions:**
1. Verify connection string in Key Vault
2. Check database firewall rules allow AKS node IPs
3. Test connection from Azure Portal → Database → Query editor
4. Verify managed identity has Key Vault access

---

### 4. High CPU/Memory Usage

**Symptoms:**
- Pods being evicted
- Slow response times
- HPA scaling up frequently

**Diagnosis:**
```bash
# Check resource usage
kubectl top pods -n production

# Check HPA status
kubectl get hpa -n production

# Check node capacity
kubectl describe nodes
```

**Solutions:**
1. Review resource requests/limits
2. Check for memory leaks in application logs
3. Consider increasing node pool size
4. Optimize application code

---

### 5. CI/CD Pipeline Failures

**Symptoms:**
- Build fails in Azure DevOps
- Docker push fails
- Deployment fails

**Diagnosis:**
- Check pipeline logs in Azure DevOps
- Verify service connections are valid
- Check variable groups contain required values

**Common Issues:**

**Docker Login Fails:**
- Verify ACR service connection credentials
- Check ACR admin user is enabled
- Regenerate ACR admin password if needed

**Kubectl Connection Fails:**
- Verify AKS service connection
- Check kubectl context: `kubectl config current-context`
- Verify service principal has AKS access

**Helm Deployment Fails:**
- Check Helm chart syntax: `helm lint auth-service/helm/auth-service`
- Verify values files are correct
- Check namespace exists: `kubectl get namespace production`

---

### 6. Application Insights Not Receiving Data

**Symptoms:**
- No telemetry in Application Insights
- Missing logs and metrics

**Diagnosis:**
```bash
# Check connection string in secrets
kubectl get secret auth-secrets -n production -o jsonpath='{.data.appinsights-connection}' | base64 -d

# Verify Application Insights resource exists
az monitor app-insights component show --app <APP_INSIGHTS_NAME> --resource-group <RG_NAME>
```

**Solutions:**
1. Verify connection string in Key Vault
2. Check Application Insights SDK is configured in code
3. Verify managed identity has Application Insights access
4. Check network connectivity (no firewall blocking)

---

### 7. Budget Alert Triggered

**Symptoms:**
- Email alert about budget threshold
- Resources may be stopped

**Diagnosis:**
```bash
# Check current costs
az consumption usage list --start-date $(date -d '1 month ago' +%Y-%m-%d) --end-date $(date +%Y-%m-%d)

# Check resource usage
az monitor metrics list --resource <RESOURCE_ID> --metric "Cost"
```

**Solutions:**
1. Review resource sizes (downsize VMs if possible)
2. Stop unused resources
3. Use Azure Cost Management to identify high-cost resources
4. Consider App Service instead of AKS for lower costs

---

### 8. Key Vault Access Denied

**Symptoms:**
- Pods cannot access secrets from Key Vault
- 403 Forbidden errors

**Diagnosis:**
```bash
# Check managed identity
az aks show --resource-group <RG> --name <AKS_NAME> --query identity

# Verify Key Vault access policies
az keyvault show --name <KV_NAME> --query properties.accessPolicies
```

**Solutions:**
1. Grant Key Vault access to AKS managed identity
2. Verify SecretProviderClass configuration
3. Check CSI driver is installed: `kubectl get daemonset -n kube-system`
4. Review Key Vault firewall rules

---

## Azure Portal Debugging Steps

### Check Resource Health
1. Azure Portal → Resource Group
2. Check resource status icons
3. Review Activity Log for errors

### Application Insights
1. Azure Portal → Application Insights
2. Live Metrics → View real-time telemetry
3. Logs → Run KQL queries
4. Failures → Check exception details

### AKS Diagnostics
1. Azure Portal → AKS Cluster
2. Insights → View cluster metrics
3. Workloads → Check pod status
4. Services and ingresses → Verify endpoints

### Key Vault
1. Azure Portal → Key Vault
2. Access policies → Verify identities
3. Secrets → Check secret values
4. Diagnostic settings → Review logs

---

## Emergency Procedures

### Rollback Deployment
```bash
# Helm rollback
helm rollback auth-service -n production

# Or kubectl rollout
kubectl rollout undo deployment/auth-service -n production
```

### Scale Down to Zero (Cost Saving)
```bash
kubectl scale deployment auth-service --replicas=0 -n production
```

### Restart All Pods
```bash
kubectl rollout restart deployment/auth-service -n production
```

### Delete and Redeploy
```bash
# Delete deployment
kubectl delete deployment auth-service -n production

# Redeploy from Helm
helm upgrade auth-service ./helm/auth-service -n production
```

---

## Useful Commands Reference

```bash
# Get all resources in namespace
kubectl get all -n production

# Watch pods
kubectl get pods -n production -w

# Port forward for local testing
kubectl port-forward svc/auth-service 5001:80 -n production

# Execute command in pod
kubectl exec -it <pod-name> -n production -- /bin/sh

# View logs with follow
kubectl logs -f -l app=auth-service -n production

# Check events
kubectl get events -n production --sort-by='.lastTimestamp'

# Describe resource
kubectl describe pod <pod-name> -n production
```

---

## Getting Help

1. Check Azure Service Health: https://status.azure.com
2. Review Azure Advisor recommendations
3. Check Application Insights Smart Detection
4. Review Log Analytics queries for patterns
5. Consult Azure documentation for specific services

