#!/bin/bash
# This script deploys BOSH to AWS using BOSH Bootloader

# Run this script from Linux machine

# IP: 54.244.61.60
# user: ubuntu
# key: ~/.ssh/lx-oregon.pem
# ssh -i ~/.ssh/lx-oregon.pem ubuntu@54.244.61.60

# Update packages to the latest versions
sudo apt-get update
sudo apt-get upgrade

# Install latest version of BOSH bootloader
# See: https://github.com/cloudfoundry/bosh-bootloader/releases/
# BBL_INSTALL="https://github.com/cloudfoundry/bosh-bootloader/releases/download/v4.7.3/bbl-v4.7.3_linux_x86-64"
BBL_INSTALL="https://github.com/cloudfoundry/bosh-bootloader/releases/download/v5.11.5/bbl-v5.11.5_linux_x86-64"
wget $BBL_INSTALL -O bbl
sudo install -m 755 -o root -g root bbl /usr/local/bin/
rm bbl
bbl version
# > bbl 5.11.5 (linux/amd64)

# Install Ruby
sudo apt-get install ruby -y

# Install Terraform
TF_INSTALL="https://releases.hashicorp.com/terraform/0.11.2/terraform_0.11.2_linux_amd64.zip"
wget $TF_INSTALL -O terraform.zip
unzip terraform.zip
sudo install -m 755 -o root -g root terraform /usr/local/bin/
rm terraform*
terraform version
# > Terraform v0.11.2

# Install BOSH CLI
# BOSH dependencies
sudo apt-get install -y build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt-dev libxml2-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3

BOSH_INSTALL="https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.45-linux-amd64"
wget $BOSH_INSTALL -O bosh
sudo install -m 755 -o root -g root bosh /usr/local/bin/
rm bosh
bosh --version
# version 2.0.45-d208799-2017-10-28T00:31:53Z

# Now create service user for it

# Install AWS CLI
sudo apt-get install awscli -y
aws --version
# > aws-cli/1.11.13 Python/3.5.2 Linux/4.4.0-1047-aws botocore/1.4.70

# Configure AWS CLI
aws configure
# AWS Access Key ID [None]: AKI...
# AWS Secret Access Key [None]: 0Ac...
# Default region name [None]: us-west-2
# Default output format [None]: json
aws ec2 describe-instances

# Create AWS user with nessesary rights
aws iam create-user --user-name "bbl-user"
aws iam put-user-policy \
  --user-name bbl-user \
  --policy-name bbl-policy \
  --policy-document file://policy.json
aws iam create-access-key --user-name bbl-user
# {
#     "AccessKey": {
#         "SecretAccessKey": "eOt..",
#         "AccessKeyId": "AKI..",
#         "Status": "Active",
#         "CreateDate": "2017-08-24T12:28:40.102Z",
#         "UserName": "bbl-user"
#     }
# }

export AWS_ACCESS_KEY="AKI.."
export AWS_SECRET_KEY="eOt.."

# Deploy BOSH Director to AWS
bbl up \
	--aws-access-key-id $AWS_ACCESS_KEY \
	--aws-secret-access-key $AWS_SECRET_KEY \
	--aws-region us-west-2 \
	--iaas aws

# Load enviornmental variables to configure BOSH cli
echo "$(bbl print-env)" > env.sh
# Replace the IP address in the SSH command at the end with your jump proxy hostname
source env.sh

# Verify deployment
bosh deployments
