#!/bin/bash

# Create a certificate policy
POLICY=$(cat << EOF
{
  "issuerParameters": {
    "certificateTransparency": null,
    "name": "Self"
  },
  "keyProperties": {
    "curve": null,
    "exportable": true,
    "keySize": 4096,
    "keyType": "RSA",
    "reuseKey": true
  },
  "lifetimeActions": [
    {
      "action": {
        "actionType": "AutoRenew"
      },
      "trigger": {
        "daysBeforeExpiry": 90
      }
    }
  ],
  "secretProperties": {
    "contentType": "application/x-pkcs12"
  },
  "x509CertificateProperties": {
    "keyUsage": [
      "cRLSign",
      "dataEncipherment",
      "digitalSignature",
      "keyEncipherment",
      "keyAgreement",
      "keyCertSign"
    ],
    "subjectAlternativeNames": {
        "dns_names": [
            "$DOMAIN_NAME"
        ],
        "emails": [],
        "upns": []
    },
    "subject": "CN=$DOMAIN_NAME",
    "validityInMonths": 12
  }
}
EOF
)

# Create a new certificate in Azure Key Vault to be used by the Application Gateway
az keyvault certificate create \
--name=$AGW_CERT_NAME \
--policy=$POLICY \
--vault-name=$KV_NAME

# Get the certificate secret id
AGW_CERT_SECRET_ID=$(az keyvault certificate show \
--name=$AGW_CERT_NAME \
--vault-name=$WORKLOAD_KV_NAME \
--query=sid \
--output=tsv)

# Set the cert in App Gateway
az network application-gateway ssl-cert create \
--resource-group=$TRANSIT_RG \
--gateway-name=$AGW_NAME \
--name=$AGW_CERT_NAME \
--key-vault-secret-id=$AGW_CERT_SECRET_ID

# Configure the https front end port
az network application-gateway frontend-port create \
--gateway-name=$AGW_NAME \
--name=https_port \
--port=443 \
--resource-group=$TRANSIT_RG

# Configure the https listener
az network application-gateway http-listener create \
--name=https_listener \
--frontend-ip=appGwPubFrontEnd \
--frontend-port=443 \
--gateway-name=$AGW_NAME \
--resource-group=$TRANSIT_RG \
--frontend-port=https_port \
--host-names=$DOMAIN_NAME \
--ssl-cert=$AGW_CERT_NAME

# Create a new address pool
az network application-gateway address-pool create \
--gateway-name=$AGW_NAME \
--name=sample-app-pool \
--resource-group=$TRANSIT_RG \
--servers=$APP_FQDN

# Create a new routing rule
az network application-gateway rule create \
--gateway-name=$AGW_NAME \
--name=https_rule \
--resource-group=$TRANSIT_RG \
--address-pool=sample-app-pool \
--http-listener=https_listener \
--http-settings=https_httpsetting