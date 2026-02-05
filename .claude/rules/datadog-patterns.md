# Datadog Codebase Patterns

## Repository Structure

### Key Repositories (aws-integrations team)
- **dogweb**: Main web application
- **datadog-serverless-functions**: AWS Lambda integrations
- **datadog-cloudformation-resources**: CloudFormation resource providers
- **documentation**: Public docs
- **integrations-internal-core**: Internal integrations

## Common Operations

### EC2 Auto-muting
- Constants: `dogweb/integration/amazon_ec2/crawler/automute_constants.py`
- Documentation: https://docs.datadoghq.com/integrations/amazon_ec2/#monitor-automuting
