#!/bin/bash
# Deployment Verification Script
# Purpose: Verifies all components are deployed and functioning correctly

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Deployment Verification ===${NC}"
echo ""

# Configuration - UPDATE THESE
RESOURCE_GROUP=""
AKS_NAME=""
ACR_NAME=""
FRONTEND_URL=""

# Check if variables are set
if [ -z "$RESOURCE_GROUP" ] || [ -z "$AKS_NAME" ]; then
    echo -e "${YELLOW}Please set RESOURCE_GROUP and AKS_NAME variables${NC}"
    exit 1
fi

ERRORS=0

# 1. Check AKS Cluster
echo -e "${YELLOW}1. Checking AKS cluster...${NC}"
if kubectl cluster-info &>/dev/null; then
    echo -e "${GREEN}   ✓ kubectl configured${NC}"
    
    # Check nodes
    NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
    if [ "$NODE_COUNT" -gt 0 ]; then
        echo -e "${GREEN}   ✓ AKS nodes running: $NODE_COUNT${NC}"
    else
        echo -e "${RED}   ✗ No nodes found${NC}"
        ((ERRORS++))
    fi
else
    echo -e "${RED}   ✗ kubectl not configured${NC}"
    ((ERRORS++))
fi

# 2. Check Pods
echo -e "${YELLOW}2. Checking pods...${NC}"
NAMESPACES=("default" "production")
for NS in "${NAMESPACES[@]}"; do
    PODS=$(kubectl get pods -n "$NS" --no-headers 2>/dev/null | grep -v Running | wc -l)
    if [ "$PODS" -eq 0 ]; then
        echo -e "${GREEN}   ✓ All pods running in namespace: $NS${NC}"
    else
        echo -e "${RED}   ✗ Some pods not running in namespace: $NS${NC}"
        kubectl get pods -n "$NS" | grep -v Running
        ((ERRORS++))
    fi
done

# 3. Check ACR
echo -e "${YELLOW}3. Checking ACR...${NC}"
if [ -n "$ACR_NAME" ]; then
    if az acr repository list --name "$ACR_NAME" &>/dev/null; then
        REPO_COUNT=$(az acr repository list --name "$ACR_NAME" --output tsv | wc -l)
        echo -e "${GREEN}   ✓ ACR accessible with $REPO_COUNT repositories${NC}"
    else
        echo -e "${RED}   ✗ Cannot access ACR${NC}"
        ((ERRORS++))
    fi
fi

# 4. Check Application Insights
echo -e "${YELLOW}4. Checking Application Insights...${NC}"
AI_NAME=$(az resource list --resource-group "$RESOURCE_GROUP" --resource-type "Microsoft.Insights/components" --query "[0].name" -o tsv 2>/dev/null)
if [ -n "$AI_NAME" ]; then
    echo -e "${GREEN}   ✓ Application Insights found: $AI_NAME${NC}"
else
    echo -e "${YELLOW}   ⚠ Application Insights not found${NC}"
fi

# 5. Check Frontend
echo -e "${YELLOW}5. Checking frontend...${NC}"
if [ -n "$FRONTEND_URL" ]; then
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_URL" || echo "000")
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}   ✓ Frontend accessible: $FRONTEND_URL${NC}"
    else
        echo -e "${RED}   ✗ Frontend not accessible (HTTP $HTTP_CODE)${NC}"
        ((ERRORS++))
    fi
fi

# 6. Test Authentication
echo -e "${YELLOW}6. Testing authentication...${NC}"
AUTH_URL="${FRONTEND_URL%/}/api/auth/login"
if [ -n "$FRONTEND_URL" ]; then
    RESPONSE=$(curl -s -X POST "$AUTH_URL" \
        -H "Content-Type: application/json" \
        -d '{"email":"admin@example.com","password":"Admin123!"}' || echo "ERROR")
    
    if echo "$RESPONSE" | grep -q "token"; then
        echo -e "${GREEN}   ✓ Authentication working${NC}"
    else
        echo -e "${RED}   ✗ Authentication failed${NC}"
        ((ERRORS++))
    fi
fi

# Summary
echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}=== Verification Complete: All checks passed ===${NC}"
    exit 0
else
    echo -e "${RED}=== Verification Complete: $ERRORS error(s) found ===${NC}"
    exit 1
fi

