# N8N IT Risk Control Validation System

An automated workflow system that validates IT risk controls by comparing security policies against real-world performance metrics and incident data.

## Overview

This N8N workflow monitors:
- **Code Vulnerabilities**: Container and library security issues
- **ServiceNow Incidents**: High priority incidents (P1-P2)
- **Service Uptime**: Monthly availability metrics
- **Risk Control Compliance**: Policy adherence validation

## Alert Logic

The system generates CIO alerts when:
- ✅ Risk controls appear to be met (low vulnerability scores)
- ❌ BUT high-priority incidents > 3/month
- ❌ AND uptime < 99%/month

This indicates a **risk mitigation gap** - controls exist on paper but aren't preventing real issues.

## Architecture

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

## Features

- 🔍 **Multi-source Data Integration**
- 📊 **Risk Correlation Analysis**
- 🚨 **Intelligent Alert System**
- 📧 **Executive Reporting**
- 🔄 **Automated Scheduling**
- 📈 **Trend Analysis**
- 🔐 **Secure API Integration**

## Quick Start

1. **Setup N8N Environment**
   ```bash
   git clone https://github.com/egbertarp/n8n-it-risk-validation.git
   cd n8n-it-risk-validation
   docker-compose up -d
   ```

2. **Configure Credentials**
   - ServiceNow API credentials
   - Vulnerability scanner API keys
   - Service Uptime portal access
   - SMTP settings for alerts

3. **Import Workflows**
   - Import `workflows/main-risk-validation.json`
   - Configure environment variables
   - Set up scheduling

4. **Test & Deploy**
   - Run test scenarios
   - Validate alert thresholds
   - Enable production monitoring

## Configuration

See `config/` directory for:
- Risk thresholds
- API endpoints
- Alert templates
- Scheduling settings

## Documentation

- [Setup Guide](docs/setup.md)
- [API Configuration](docs/api-config.md)
- [Alert Customization](docs/alerts.md)
- [Troubleshooting](docs/troubleshooting.md)

## License

MIT License - See [LICENSE](LICENSE) file for details.