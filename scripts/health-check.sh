#!/bin/bash

# Health Check Script for N8N IT Risk Validation System
# Usage: ./scripts/health-check.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Starting IT Risk Validation System Health Check..."
echo "================================================"

# Function to check if service is running
check_service() {
    local service_name=$1
    local container_name=$2
    
    echo -n "Checking $service_name... "
    
    if docker ps | grep -q $container_name; then
        echo -e "${GREEN}✅ Running${NC}"
        return 0
    else
        echo -e "${RED}❌ Not Running${NC}"
        return 1
    fi
}

# Function to check API endpoint
check_api() {
    local service_name=$1
    local url=$2
    local expected_status=$3
    local auth_header=$4
    
    echo -n "Testing $service_name API... "
    
    if [ -n "$auth_header" ]; then
        response=$(curl -s -o /dev/null -w "%{http_code}" -H "$auth_header" "$url" || echo "000")
    else
        response=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
    fi
    
    if [ "$response" = "$expected_status" ]; then
        echo -e "${GREEN}✅ OK ($response)${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed ($response)${NC}"
        return 1
    fi
}

# Function to load environment variables
load_env() {
    if [ -f .env ]; then
        source .env
        echo -e "${GREEN}✅ Environment loaded${NC}"
    else
        echo -e "${YELLOW}⚠️ No .env file found${NC}"
    fi
}

# Main health checks
main() {
    local failed_checks=0
    
    echo "1. Loading Environment Variables"
    load_env
    echo ""
    
    echo "2. Checking Docker Services"
    check_service "N8N" "n8n-risk-validation" || ((failed_checks++))
    check_service "PostgreSQL" "n8n-postgres" || ((failed_checks++))
    check_service "Redis" "n8n-redis" || ((failed_checks++))
    echo ""
    
    echo "3. Checking N8N Web Interface"
    check_api "N8N UI" "http://localhost:5678" "200" || ((failed_checks++))
    echo ""
    
    echo "4. Testing External APIs"
    
    # ServiceNow API Check
    if [ -n "$SERVICENOW_INSTANCE" ] && [ -n "$SERVICENOW_USERNAME" ] && [ -n "$SERVICENOW_PASSWORD" ]; then
        auth_header="Authorization: Basic $(echo -n "$SERVICENOW_USERNAME:$SERVICENOW_PASSWORD" | base64)"
        check_api "ServiceNow" "https://$SERVICENOW_INSTANCE/api/now/table/incident?sysparm_limit=1" "200" "$auth_header" || ((failed_checks++))
    else
        echo -e "ServiceNow API... ${YELLOW}⚠️ Configuration missing${NC}"
    fi
    
    # Snyk API Check
    if [ -n "$SNYK_API_TOKEN" ]; then
        auth_header="Authorization: token $SNYK_API_TOKEN"
        check_api "Snyk" "https://snyk.io/api/v1/orgs" "200" "$auth_header" || ((failed_checks++))
    else
        echo -e "Snyk API... ${YELLOW}⚠️ Configuration missing${NC}"
    fi
    
    # Uptime Portal Check
    if [ -n "$UPTIME_PORTAL_URL" ] && [ -n "$UPTIME_API_KEY" ]; then
        auth_header="Authorization: Bearer $UPTIME_API_KEY"
        check_api "Uptime Portal" "$UPTIME_PORTAL_URL/health" "200" "$auth_header" || ((failed_checks++))
    else
        echo -e "Uptime Portal... ${YELLOW}⚠️ Configuration missing${NC}"
    fi
    
    echo ""
    
    echo "5. Checking SMTP Configuration"
    if [ -n "$SMTP_HOST" ] && [ -n "$SMTP_USER" ]; then
        echo -n "SMTP Settings... "
        # Basic connectivity check (telnet alternative)
        if timeout 5 bash -c "</dev/tcp/$SMTP_HOST/$SMTP_PORT" 2>/dev/null; then
            echo -e "${GREEN}✅ SMTP server reachable${NC}"
        else
            echo -e "${RED}❌ Cannot reach SMTP server${NC}"
            ((failed_checks++))
        fi
    else
        echo -e "SMTP Configuration... ${YELLOW}⚠️ Configuration missing${NC}"
    fi
    
    echo ""
    
    echo "6. Checking Disk Space"
    echo -n "Docker volumes... "
    disk_usage=$(docker system df --format "table {{.Type}}\t{{.Size}}" | tail -n +2 | awk '{print $2}' | head -1)
    echo -e "${GREEN}✅ Using $disk_usage${NC}"
    
    echo ""
    
    echo "7. Recent Workflow Executions"
    echo -n "Checking N8N logs... "
    if docker logs --tail 10 n8n-risk-validation 2>/dev/null | grep -q "Workflow"; then
        echo -e "${GREEN}✅ Recent activity found${NC}"
    else
        echo -e "${YELLOW}⚠️ No recent workflow activity${NC}"
    fi
    
    echo ""
    echo "================================================"
    
    if [ $failed_checks -eq 0 ]; then
        echo -e "${GREEN}🎉 All health checks passed!${NC}"
        exit 0
    else
        echo -e "${RED}❌ $failed_checks health check(s) failed${NC}"
        echo ""
        echo "Troubleshooting steps:"
        echo "1. Check the troubleshooting guide: docs/troubleshooting.md"
        echo "2. Review Docker logs: docker-compose logs"
        echo "3. Verify environment configuration: .env file"
        echo "4. Restart services if needed: docker-compose restart"
        exit 1
    fi
}

# Run main function
main "$@"