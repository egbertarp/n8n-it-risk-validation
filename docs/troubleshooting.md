# Troubleshooting Guide

## Common Issues

### 1. Workflow Execution Errors

#### "Cannot connect to ServiceNow"
**Symptoms:**
- HTTP 401 Unauthorized errors
- Connection timeout errors

**Solutions:**
1. **Check Credentials:**
   ```bash
   # Test ServiceNow connection
   curl -u "username:password" \
     "https://your-instance.service-now.com/api/now/table/incident?sysparm_limit=1"
   ```

2. **Verify Instance URL:**
   - Ensure no trailing slashes
   - Use correct instance subdomain
   - Check if instance is active

3. **Check User Permissions:**
   - User needs `incident.read` role
   - Account must not be locked
   - MFA might interfere with API access

#### "Snyk API Rate Limited"
**Symptoms:**
- HTTP 429 errors
- "Rate limit exceeded" messages

**Solutions:**
1. **Implement Rate Limiting:**
   ```javascript
   // Add delay between requests in N8N Function node
   await new Promise(resolve => setTimeout(resolve, 1000));
   ```

2. **Optimize API Calls:**
   - Use batch endpoints where available
   - Filter results server-side
   - Cache results between workflow runs

3. **Check API Limits:**
   - Free tier: 200 requests/month
   - Paid plans: higher limits
   - Monitor usage in Snyk dashboard

### 2. Email Delivery Issues

#### "SMTP Authentication Failed"
**Solutions:**
1. **Gmail/Google Workspace:**
   ```bash
   # Use App Password, not regular password
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USER=your-email@company.com
   SMTP_PASSWORD=app-specific-password  # Not your regular password
   ```

2. **Office 365:**
   ```bash
   SMTP_HOST=smtp.office365.com
   SMTP_PORT=587
   # Enable SMTP AUTH in Office 365 admin center
   ```

3. **Corporate SMTP:**
   - Check firewall rules
   - Verify TLS/SSL settings
   - Confirm relay permissions

#### "Emails Not Delivered"
**Debugging Steps:**
1. **Check Spam Folders**
2. **Verify Email Addresses**
3. **Test with Simple Email:**
   ```javascript
   // Minimal test email in N8N
   {
     "subject": "Test Alert System",
     "body": "This is a test email from the risk validation system.",
     "to": "test@company.com"
   }
   ```

### 3. Data Processing Issues

#### "Uptime Calculation Incorrect"
**Common Causes:**
1. **Timezone Mismatches:**
   ```javascript
   // Ensure consistent timezone handling
   const date = new Date().toISOString(); // Always use UTC
   ```

2. **API Response Format Changes:**
   - Uptime APIs may change response structure
   - Add defensive programming:
   ```javascript
   const uptimePercentage = data.uptime?.percentage || 
                           data.availability || 
                           (data.uptime_minutes / data.total_minutes) * 100;
   ```

3. **Missing Data Points:**
   - Handle partial data gracefully
   - Use previous month as fallback

#### "Incident Count Mismatch"
**Debugging:**
1. **Check ServiceNow Query:**
   ```javascript
   // Debug query in ServiceNow
   "sysparm_query": "priority=1^ORpriority=2^opened_at>=2024-01-01^opened_at<=2024-01-31"
   ```

2. **Verify Date Ranges:**
   ```javascript
   // Log date calculations
   console.log('Period start:', periodStart);
   console.log('Period end:', periodEnd);
   ```

3. **Check Priority Mapping:**
   - P1 = priority=1
   - P2 = priority=2
   - Verify your org's priority scheme

### 4. N8N Platform Issues

#### "Workflow Stuck in 'Running' State"
**Solutions:**
1. **Check Node Timeouts:**
   - Set reasonable timeouts on HTTP Request nodes
   - Default is often too long

2. **Memory Issues:**
   ```bash
   # Check container resources
   docker stats n8n-risk-validation
   ```

3. **Manual Intervention:**
   ```bash
   # Restart N8N container
   docker-compose restart n8n
   ```

#### "Credentials Not Working"
**Solutions:**
1. **Re-create Credentials:**
   - Delete and recreate in N8N interface
   - Ensure correct credential type

2. **Environment Variables:**
   ```bash
   # Check if env vars are loaded
   docker exec -it n8n-risk-validation printenv | grep SERVICENOW
   ```

3. **Credential Scope:**
   - Ensure credentials are assigned to correct nodes
   - Check credential permissions

### 5. Performance Issues

#### "Workflow Takes Too Long"
**Optimizations:**
1. **Parallel Processing:**
   - Use parallel branches for independent API calls
   - Merge results afterwards

2. **Reduce Data Volume:**
   ```javascript
   // Limit ServiceNow results
   "sysparm_limit": "100",
   "sysparm_fields": "number,priority,opened_at"  // Only needed fields
   ```

3. **Caching:**
   - Store intermediate results
   - Skip unchanged data

#### "High Memory Usage"
**Solutions:**
1. **Process Data in Chunks:**
   ```javascript
   // Split large datasets
   const chunks = data.reduce((acc, item, index) => {
     const chunkIndex = Math.floor(index / 100);
     acc[chunkIndex] = acc[chunkIndex] || [];
     acc[chunkIndex].push(item);
     return acc;
   }, []);
   ```

2. **Clear Unused Variables:**
   ```javascript
   // Clean up large objects
   delete largeDataObject;
   ```

## Monitoring and Alerting

### Workflow Health Checks

#### Create Health Check Workflow
```javascript
// Simple health check function
const healthChecks = [
  {
    name: 'ServiceNow API',
    test: () => fetch('https://instance.service-now.com/api/now/table/incident?sysparm_limit=1')
  },
  {
    name: 'Snyk API', 
    test: () => fetch('https://snyk.io/api/v1/orgs')
  },
  {
    name: 'SMTP Server',
    test: () => sendTestEmail()
  }
];

// Run checks and report status
for (const check of healthChecks) {
  try {
    await check.test();
    console.log(`✅ ${check.name}: OK`);
  } catch (error) {
    console.log(`❌ ${check.name}: ${error.message}`);
  }
}
```

### Log Analysis

#### Enable Detailed Logging
1. **N8N Settings:**
   ```yaml
   # docker-compose.yml
   environment:
     - N8N_LOG_LEVEL=debug
     - N8N_LOG_OUTPUT=console,file
   ```

2. **Custom Logging:**
   ```javascript
   // In Function nodes
   console.log('Processing data:', JSON.stringify(data, null, 2));
   ```

#### Log Retention
```bash
# Rotate logs to prevent disk space issues
docker run --rm -v n8n_data:/data alpine sh -c '
  find /data/logs -name "*.log" -mtime +30 -delete
'
```

## Emergency Procedures

### Critical System Failure

1. **Immediate Actions:**
   ```bash
   # Stop all workflows
   docker-compose down
   
   # Backup current state
   docker run --rm -v n8n_data:/source -v $(pwd)/backup:/backup alpine \
     tar czf /backup/n8n-backup-$(date +%Y%m%d).tar.gz -C /source .
   
   # Restart with clean state if needed
   docker-compose up -d
   ```

2. **Manual Alert Process:**
   - If automated system fails, use manual email template
   - Contact list: CIO, CISO, IT Director
   - Include key metrics from last successful run

3. **Recovery Verification:**
   ```bash
   # Test all integrations
   ./scripts/health-check.sh
   
   # Run workflow manually
   # Verify email delivery
   # Check log output
   ```

### False Positive Handling

#### When System Generates Incorrect Alerts

1. **Immediate Response:**
   - Send correction email to recipients
   - Document the false positive cause
   - Adjust thresholds temporarily if needed

2. **Root Cause Analysis:**
   - Check data source APIs for changes
   - Verify date/time calculations
   - Review threshold logic

3. **Prevention:**
   - Add data validation steps
   - Implement sanity checks
   - Create test scenarios

## Getting Help

### Support Channels

1. **Internal Team:**
   - IT Operations: Day-to-day issues
   - Security Team: Risk threshold questions
   - Development Team: Workflow modifications

2. **External Resources:**
   - N8N Community Forum
   - ServiceNow Developer Community
   - Vulnerability Scanner Support

3. **Documentation:**
   - API documentation for each integrated service
   - N8N node documentation
   - This project's GitHub issues

### Creating Support Tickets

**Include This Information:**
- Workflow execution ID
- Error messages (full stack trace)
- Environment details (N8N version, Docker version)
- Steps to reproduce
- Expected vs actual behavior
- Recent changes to configuration

**Log Collection:**
```bash
# Collect relevant logs
docker logs n8n-risk-validation > n8n-logs.txt
docker logs n8n-postgres > postgres-logs.txt

# Export workflow for analysis
# (Use N8N UI to export workflow JSON)
```