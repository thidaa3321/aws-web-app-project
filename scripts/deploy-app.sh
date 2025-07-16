#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Check prerequisites
log_info "Checking prerequisites..."
command -v aws >/dev/null 2>&1 || log_error "AWS CLI not installed"
command -v terraform >/dev/null 2>&1 || log_error "Terraform not installed"
command -v git >/dev/null 2>&1 || log_error "Git not installed"
aws sts get-caller-identity >/dev/null 2>&1 || log_error "AWS credentials not configured"

# Create placeholder logo if missing
if [ ! -f "web-app/images/logo.png" ]; then
    log_info "Creating placeholder logo..."
    mkdir -p web-app/images
    if command -v magick >/dev/null 2>&1; then
        magick -size 48x48 xc:gray -fill white -gravity center -pointsize 12 -annotate +0+0 "LOGO" web-app/images/logo.png
    elif command -v convert >/dev/null 2>&1; then
        convert -size 48x48 xc:gray -fill white -gravity center -pointsize 12 -annotate +0+0 "LOGO" web-app/images/logo.png
    else
        echo "Placeholder logo" > web-app/images/logo.png
        log_info "ImageMagick not found; created text placeholder for logo.png"
    fi
fi

# Terraform operations
cd terraform
log_info "Initializing Terraform..."
terraform init || log_error "Terraform init failed"
log_info "Validating configuration..."
terraform validate || log_error "Terraform validation failed"
log_info "Planning deployment..."
terraform plan -out=tfplan || log_error "Terraform plan failed"

# Prompt for confirmation
log_info "Apply Terraform configuration? (y/n)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    log_info "Deployment cancelled"
    rm -f tfplan
    exit 0
fi

log_info "Applying Terraform configuration..."
terraform apply tfplan || log_error "Terraform apply failed"

# Get outputs
ALB_DNS=$(terraform output -raw load_balancer_dns)
log_info "Application URL: http://$ALB_DNS"

# Test deployment
log_info "Testing deployment..."
for i in {1..5}; do
    if curl -f "http://$ALB_DNS/health" >/dev/null 2>&1; then
        log_info "Application is healthy at http://$ALB_DNS"
        break
    else
        log_info "Waiting for application (attempt $i/5)..."
        sleep 30
    fi
done

log_info "Deployment complete! Check CloudWatch dashboard for monitoring."
cd ..
rm -f terraform/tfplan
