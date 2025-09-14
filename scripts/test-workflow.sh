#!/bin/bash

# Test Script for N8N IT Risk Validation Workflow
# Usage: ./scripts/test-workflow.sh [workflow-name]

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

WORKFLOW_NAME=${1:-"IT Risk Control Validation - Main Workflow"}
N8N_URL="http://localhost:5678"

echo "🧪 Testing N8N Workflow: $WORKFLOW_NAME"
echo "================================================"

# Function to execute workflow via N8N API
execute_workflow() {
    local workflow_name=$1
    
    echo "Triggering workflow execution..."
    
    # Note: This requires N8N API access and proper authentication
    # In a real environment, you'd use N8N's webhook or API endpoints
    
    # For now, provide manual instructions
    echo -e "${YELLOW}Manual Test Steps:${NC}"
    echo "1. Open N8N UI: $N8N_URL"
    echo "2. Find workflow: '$workflow_name'"
    echo "3. Click 'Execute Workflow' button"
    echo "4. Monitor execution in the UI"
    echo ""
    
    echo "Expected Results:"
    echo "✅ All nodes should execute without errors"
    echo "✅ Data should be collected from all sources"
    echo "✅ Risk assessment should complete"
    echo "✅ If risk gap detected, email should be prepared"
    echo ""
    
    read -p "Press Enter after running the workflow manually..."
}

# Function to check test results
check_results() {
    echo "Checking recent workflow execution..."
    
    # Check N8N logs for recent activity
    if docker logs --tail 50 n8n-risk-validation 2>/dev/null | grep -i "workflow.*completed\|execution.*finished" > /dev/null; then
        echo -e "${GREEN}✅ Recent workflow execution found${NC}"
    else
        echo -e "${YELLOW}⚠️ No recent execution found in logs${NC}"
    fi
    
    # Check for any errors
    if docker logs --tail 50 n8n-risk-validation 2>/dev/null | grep -i "error\|failed" > /dev/null; then
        echo -e "${RED}❌ Errors found in recent logs:${NC}"
        docker logs --tail 20 n8n-risk-validation 2>/dev/null | grep -i "error\|failed" | tail -5
    else
        echo -e "${GREEN}✅ No errors in recent logs${NC}"
    fi
}

# Function to run data validation tests
test_data_sources() {
    echo ""
    echo "Testing Individual Data Sources:"
    echo "--------------------------------"
    
    # Source environment variables
    if [ -f .env ]; then
        source .env
    fi
    
    # Test ServiceNow API
    if [ -n "$SERVICENOW_INSTANCE" ] && [ -n "$SERVICENOW_USERNAME" ]; then
        echo -n "ServiceNow API... "
        if curl -s -u "$SERVICENOW_USERNAME:$SERVICENOW_PASSWORD" \
            "https://$SERVICENOW_INSTANCE/api/now/table/incident?sysparm_limit=1" > /dev/null; then
            echo -e "${GREEN}✅ OK${NC}"
        else
            echo -e "${RED}❌ Failed${NC}"
        fi
    fi
    
    # Test Snyk API
    if [ -n "$SNYK_API_TOKEN" ]; then
        echo -n "Snyk API... "
        if curl -s -H "Authorization: token $SNYK_API_TOKEN" \
            "https://snyk.io/api/v1/orgs" > /dev/null; then
            echo -e "${GREEN}✅ OK${NC}"
        else
            echo -e "${RED}❌ Failed${NC}"
        fi
    fi
    
    # Test SMTP (basic connectivity)
    if [ -n "$SMTP_HOST" ] && [ -n "$SMTP_PORT" ]; then
        echo -n "SMTP Server... "
        if timeout 5 bash -c "</dev/tcp/$SMTP_HOST/$SMTP_PORT" 2>/dev/null; then
            echo -e "${GREEN}✅ Reachable${NC}"
        else
            echo -e "${RED}❌ Unreachable${NC}"
        fi
    fi
}

# Function to create test data scenario
create_test_scenario() {
    echo ""
    echo "Test Scenario Options:"
    echo "1. Normal operations (should not trigger alert)"
    echo "2. High incidents but good uptime (should trigger alert if vulns are low)"
    echo "3. Poor uptime but low incidents (should trigger alert if vulns are low)"
    echo "4. Both high incidents and poor uptime (should definitely trigger alert)"
    echo ""
    
    echo "To test specific scenarios, you can temporarily modify:"
    echo "- config/risk-thresholds.json (lower thresholds for testing)"
    echo "- Test data in the workflow function nodes"
    echo "- Create test incidents in ServiceNow"
}

# Function to validate email template
test_email_template() {
    echo ""
    echo "Testing Email Template:"
    echo "----------------------"
    
    # Create sample data for template testing
    cat > /tmp/test-email-data.json << EOF
{
  "cio_name": "Test CIO",
  "period": "Test Period",
  "critical_vulns": 0,
  "critical_target": 0,
  "high_vulns": 3,
  "high_target": 5,
  "high_incidents": 5,
  "uptime_percentage": 98.5,
  "downtime_hours": 10.8,
  "revenue_impact": "$108,000",
  "customer_impact": "HIGH",
  "compliance_risk": "HIGH",
  "timestamp": "$(date)",
  "next_check": "Next business day 8:00 AM"
}
EOF
    
    echo "Sample email data created at /tmp/test-email-data.json"
    echo "You can use this data to test email templates manually in N8N"
}

# Main execution
main() {
    # Check if N8N is running
    if ! docker ps | grep -q "n8n-risk-validation"; then
        echo -e "${RED}❌ N8N container is not running${NC}"
        echo "Start with: docker-compose up -d"
        exit 1
    fi
    
    # Run tests
    test_data_sources
    create_test_scenario
    test_email_template
    
    echo ""
    execute_workflow "$WORKFLOW_NAME"
    
    echo ""
    check_results
    
    echo ""
    echo "================================================"
    echo -e "${GREEN}✅ Test execution completed${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Review workflow execution results in N8N UI"
    echo "2. Check email delivery if alert was triggered"
    echo "3. Validate data accuracy in the results"
    echo "4. Adjust thresholds in config/risk-thresholds.json if needed"
}

# Make script executable and run
chmod +x "$0"
main "$@"