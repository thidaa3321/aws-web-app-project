#AWS Web Application Project
A scalable web application deployed on AWS using Terraform, featuring high availability, monitoring, and security best practices.
Architecture

EC2: Hosts the web application
S3: Stores static assets (HTML, CSS, JS, images)
ALB: Distributes traffic across EC2 instances
Auto Scaling: Adjusts instance count based on CPU load
CloudWatch: Monitors performance and logs
VPC: Isolates resources with public/private subnets
IAM: Enforces least-privilege access

Prerequisites

AWS account with admin permissions
AWS CLI configured
Terraform >= 1.5
Git

Setup

Clone the repository:git clone https://github.com/your-username/aws-web-app-project.git
cd aws-web-app-project


Configure AWS CLI:aws configure


Deploy:chmod +x scripts/deploy-app.sh
./scripts/deploy-app.sh


Access: Use the Load Balancer DNS output by the script.

Monitoring

CloudWatch Dashboard: View CPU, request count, and response time metrics.
Logs: Check /aws/ec2/aws-web-app log group for Apache logs.

Testing Auto Scaling

Install Apache Bench:sudo yum install -y httpd-tools


Simulate load:ab -n 1000 -c 50 http://<your-alb-dns>/


Monitor scaling in the AWS Console (EC2 > Auto Scaling Groups).

Cleanup
cd terraform
terraform destroy

Troubleshooting

Application not accessible: Verify security groups, ALB target group health, and EC2 instance status.
Static assets not loading: Check S3 bucket policy and file paths.
Auto Scaling issues: Review CloudWatch alarms and scaling policies.
 aws-web-app-project
