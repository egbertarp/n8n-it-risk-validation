# N8N IT Risk Control Validation System

## 🎯 Project Overview

This N8N automation project validates IT risk controls by comparing security compliance metrics against real-world performance indicators. It detects critical \"risk mitigation gaps\" where security controls appear compliant on paper but actual service performance suggests otherwise.

## 🚨 Alert Logic

The system generates **CIO-level alerts** when:
- ✅ **Security controls appear compliant** (low vulnerability counts)
- ❌ **BUT** high-priority incidents > 3/month 
- ❌ **AND** service uptime < 99%

This combination indicates potential issues with:
- Runtime security effectiveness
- Control implementation quality  
- Incident response capabilities
- Infrastructure resilience

## 🏗️ Architecture Components

### Data Sources
- **ServiceNow**: P1/P2 incident tracking
- **Snyk/Aqua/Twistlock**: Container & library vulnerabilities
- **Uptime Portal**: Service availability metrics

### Core Workflow
1. **Data Collection**: Parallel API calls to all sources
2. **Risk Assessment**: Intelligent correlation analysis
3. **Alert Generation**: CIO email with actionable insights
4. **Trend Analysis**: Historical pattern recognition

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Vulnerability │    │   ServiceNow     │    │  Service Uptime │
│   Scanner APIs  │    │   Incident API   │    │    Portal API   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                         ┌───────▼────────┐
                         │   N8N Workflow │
                         │   Risk Engine  │
                         └───────┬────────┘
                                 │
                         ┌───────▼────────┐
                         │  Alert System  │
                         │  (Email to CIO)│
                         └────────────────┘
```

## 🚀 Quick Start

```bash
# 1. Clone and setup
git clone https://github.com/egbertarp/n8n-it-risk-validation.git
cd n8n-it-risk-validation

# 2. Configure environment
cp .env.example .env
# Edit .env with your API credentials

# 3. Start services
docker-compose up -d

# 4. Access N8N
open http://localhost:5678
# Login with credentials from .env

# 5. Import workflow
# Go to N8N UI → Import → workflows/main-risk-validation.json

# 6. Test system
./scripts/health-check.sh
./scripts/test-workflow.sh
```

## 📋 Configuration Checklist

### Required Integrations
- [ ] ServiceNow API credentials
- [ ] Vulnerability scanner API (Snyk/Aqua/Twistlock)
- [ ] Service uptime monitoring API
- [ ] SMTP email configuration
- [ ] CIO email address

### Risk Thresholds (Configurable)
- [ ] Max high-priority incidents: **3/month**
- [ ] Minimum uptime: **99%**
- [ ] Max critical vulnerabilities: **0**
- [ ] Max high vulnerabilities: **5**

## 📊 Key Features

### Intelligent Risk Correlation
- Cross-references security metrics with operational performance
- Identifies gaps between policy compliance and real-world results
- Calculates business impact (revenue loss, customer satisfaction)

### Executive Reporting
- Professional HTML email templates
- Clear risk visualization with color coding
- Actionable recommendations for immediate response
- Trend analysis and historical context

### Automated Scheduling
- Monthly comprehensive assessments
- Daily critical issue monitoring
- Configurable alert thresholds
- Emergency escalation procedures

### Multi-Source Integration
- **ServiceNow**: Incident management data
- **Vulnerability Scanners**: Security compliance metrics
- **Monitoring Tools**: Infrastructure performance
- **SMTP**: Professional email delivery

## 📈 Business Value

### Risk Management
- **Early Warning System**: Detect control failures before major incidents
- **Executive Visibility**: Keep leadership informed of real risks
- **Compliance Validation**: Verify controls are actually effective
- **Resource Optimization**: Focus security efforts where needed

### Operational Benefits
- **Automated Monitoring**: Reduce manual risk assessment overhead
- **Consistent Reporting**: Standardized metrics and thresholds
- **Historical Tracking**: Trend analysis and improvement measurement
- **Integration**: Leverage existing tools and data sources

## 🔧 Technical Architecture

### File Structure
```
n8n-it-risk-validation/
├── workflows/
│   └── main-risk-validation.json    # Main N8N workflow
├── config/
│   ├── risk-thresholds.json         # Configurable thresholds
│   └── alert-templates.json         # Email template config
├── templates/
│   └── risk-mitigation-gap.html     # CIO alert email template
├── docs/
│   ├── setup.md                     # Installation guide
│   ├── api-config.md               # API integration details
│   └── troubleshooting.md          # Common issues & solutions
├── scripts/
│   ├── health-check.sh             # System health validation
│   └── test-workflow.sh            # Workflow testing
├── docker-compose.yml              # Container orchestration
├── .env.example                    # Environment template
└── README.md                       # This file
```

## 🛡️ Security Considerations

### Credential Management
- All API keys stored in N8N credential store
- Environment variables for sensitive configuration
- Service accounts with minimal required permissions
- Regular credential rotation procedures

### Data Protection
- No sensitive data stored in workflow definitions
- Secure API communications (HTTPS/TLS)
- Access logging for audit compliance
- Data retention policies for reports

## 📝 Sample Alert Email

```
🚨 IT Risk Mitigation Gap Alert

Executive Summary:
While security controls appear compliant, we're experiencing 
performance issues that suggest control effectiveness gaps.

Current Metrics (Last 30 Days):
✅ Vulnerability Controls: COMPLIANT
   • Critical: 0 (Target: ≤ 0)
   • High: 3 (Target: ≤ 5)

❌ Service Performance: NON-COMPLIANT  
   • High Priority Incidents: 7 (Target: ≤ 3)
   • Service Uptime: 98.2% (Target: ≥ 99%)
   • Downtime: 12.9 hours

Business Impact:
   • Revenue Impact: $129,000
   • Customer Risk: HIGH
   • Compliance Risk: HIGH

Immediate Actions Required:
1. Emergency review of recent security changes
2. Deep-dive analysis of 7 high-priority incidents  
3. Performance impact assessment of security controls
4. Emergency stakeholder meeting
```

## 🔄 Workflow Schedule

### Monthly Risk Assessment
- **When**: 1st day of each month, 9:00 AM
- **Scope**: Complete risk validation across all systems
- **Output**: Comprehensive report to CIO/CISO
- **Duration**: ~15-30 minutes

### Daily Critical Monitoring  
- **When**: Weekdays, 8:00 AM
- **Scope**: Critical vulnerabilities and P1 incidents
- **Output**: Alert only if critical thresholds exceeded
- **Duration**: ~2-5 minutes

## 🎛️ Customization Options

### Adjustable Thresholds
Edit `config/risk-thresholds.json`:
```json
{
  \"incidents\": {
    \"priority_1\": {\"max_per_month\": 1},
    \"priority_2\": {\"max_per_month\": 3}
  },
  \"uptime\": {
    \"minimum_percentage\": 99.0
  },
  \"vulnerabilities\": {
    \"critical\": {\"max_allowed\": 0},
    \"high\": {\"max_allowed\": 5}
  }
}
```

## 🚀 Deployment Options

### Development/Testing
```bash
# Local development
docker-compose up -d
# Access: http://localhost:5678
```

### Production Deployment
```bash
# Production with SSL
docker-compose -f docker-compose.prod.yml up -d
# Configure reverse proxy (nginx/Apache)
# Set up monitoring and backups
```

## 📞 Support & Maintenance

### Monitoring
- System health checks every 15 minutes
- Workflow execution logging
- API response time tracking
- Email delivery confirmation

### Backup Strategy
- Daily N8N workflow backups
- Configuration file versioning
- Database snapshots (PostgreSQL)
- Credential backup procedures

## 📚 Documentation

- [Setup Guide](docs/setup.md) - Complete installation instructions
- [API Configuration](docs/api-config.md) - Integration details for all APIs
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions
- [Health Check Script](scripts/health-check.sh) - System validation
- [Test Workflow Script](scripts/test-workflow.sh) - Workflow testing

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

---

## 🏷️ Tags
`n8n` `risk-management` `automation` `security` `monitoring` `servicenow` `vulnerability-management` `executive-reporting` `docker` `integration`"