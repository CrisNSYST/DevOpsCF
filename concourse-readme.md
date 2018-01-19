# Concourse / UAA / LDAP integration

This deploys:
1. postgres in its own VM
1. UAA, Credhub, ATC, and all remaining Concourse components in another VM

Concourse is integrated with UAA for team auth.  Note that we must add the UAA CA cert
to the OS truststore.  See the cacerts-release bosh release in this same repo.

Add the LDAP CA cert to a file and pass to bosh deploy like this: `--var-file=ldap-ca-cert=ldap-ca-cert.txt`

Deploy to bosh-lite with:
```
bosh -d concourse deploy \
  --var-file=ldap-ca-cert=ldap-ca-cert.txt \
  -v deployment_name=concourse \
  -v internal-ip-address=10.244.0.2 \
  -v db-ip-address=10.244.0.3 \
  -v external-ip-address=10.244.0.2 \
  --vars-store=vars.yml \
  concourse-multiple-vm-uaa-integration.yml
```

Create teams with oauth like this example for the QA team (that has a corresponding QA LDAP group):
```
fly -t targetname set-team \
  -n QA \
  --generic-oauth-display-name 'UAA (OAuth) - QA' \
  --generic-oauth-client-id concourse \
  --generic-oauth-client-secret $(bosh int vars.yml --path /concourse_client_secret) \
  --generic-oauth-auth-url https://10.244.0.2:8443/oauth/authorize \
  --generic-oauth-token-url https://10.244.0.2:8443/oauth/token \
  --generic-oauth-scope QA
```
