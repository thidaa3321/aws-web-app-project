#!/bin/bash

set -e

# Update system
yum update -y

# Install dependencies
yum install -y httpd aws-cli amazon-cloudwatch-agent

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create web directory
mkdir -p /var/www/html/{css,js,images}

# Download static assets from S3
aws s3 cp s3://${s3_bucket}/index.html /var/www/html/index.html
aws s3 cp s3://${s3_bucket}/css/style.css /var/www/html/css/style.css
aws s3 cp s3://${s3_bucket}/js/app.js /var/www/html/js/app.js
aws s3 cp s3://${s3_bucket}/images/logo.png /var/www/html/images/logo.png

# Create health check endpoint
cat > /var/www/html/health << 'EOF'
#!/bin/bash
echo "Content-Type: application/json"
echo ""
echo "{\"status\": \"healthy\", \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\", \"instance\": \"$(curl -s http://169.254.169.254/latest/meta-data/instance-id)\"}"
EOF
chmod +x /var/www/html/health

# Configure CloudWatch Agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "/aws/ec2/${project_name}",
            "log_stream_name": "{instance_id}/access_log"
          },
          {
            "file_path": "/var/log/httpd/error_log",
            "log_group_name": "/aws/ec2/${project_name}",
            "log_stream_name": "{instance_id}/error_log"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "${project_name}/Metrics",
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_active"],
        "metrics_collection_interval": 60
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# Set permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Configure Apache
cat > /etc/httpd/conf.d/webapp.conf << 'EOF'
<VirtualHost *:80>
    DocumentRoot /var/www/html
    ErrorLog /var/log/httpd/error_log
    CustomLog /var/log/httpd/access_log combined
    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Restart Apache
systemctl restart httpd

echo "Web server setup complete"
