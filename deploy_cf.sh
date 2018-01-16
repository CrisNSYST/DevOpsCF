#!/bin/bash

# The script shows how to deploy Cloud Foundry using cf-deployment and bosh v2
# CLI on AWS

# First you need to generate self-signed SSL certificates. If you have real SSL
# certificates then you can skip this step

mkdir ssl
openssl req \
    -newkey rsa:2048 -nodes -keyout ssl/cf  .altoros.cf.key \
    -out ssl/cf.altoros.cf.crt \
    -sha256 \
    -subj "/C=CA/ST=Ontario/L=Toronto/O=Altoros/CN=*.cf.altoros.cf" \
    -x509 -days 365

# Now create load balancers for HTTP(S), SSH and TCP traffic
export AWS_ACCESS_KEY="AKI.."
export AWS_SECRET_KEY="eOt.."
bbl create-lbs \
  --aws-access-key-id $AWS_ACCESS_KEY \
  --aws-secret-access-key $AWS_SECRET_KEY \
  --type cf \
  --cert ssl/cf.altoros.cf.crt \
  --key ssl/cf.altoros.cf.key

# Now point your DNS name to loadbalancers (external action)
# *.cf => HTTP(S)
# ssh.cf => SSH
# tcp.cf => tcp
# You can find the names of the load balancers using the command below
bbl lbs

# Upload stemcell to BOSH Director
# Get latest version URL from https://bosh.io/stemcells/bosh-aws-xen-hvm-ubuntu-trusty-go_agent
bosh upload-stemcell https://bosh.io/d/stemcells/bosh-aws-xen-hvm-ubuntu-trusty-go_agent?v=3468.17

# Clone cf-deployment locally
git clone https://github.com/cloudfoundry/cf-deployment.git
cd cf-deployment

# Set system domain in deployment variables
echo "system_domain: cf.altoros.cf" > cf-deployment-vars.yml

# Interpolate the manifest with variables and operations to verify its
# correctness
bosh -n interpolate \
  --vars-store cf-deployment-vars.yml \
  -o operations/scale-to-one-az.yml \
  -o operations/aws.yml \
  --var-errs cf-deployment.yml

# Start deployment
bosh -d cf deploy  \
  --vars-store cf-deployment-vars.yml \
  -o operations/scale-to-one-az.yml \
  -o operations/aws.yml \
  cf-deployment.yml
