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
echo $POLICY >> ./policy.json

AGW_CERT_SECRET_ID=$(az keyvault certificate show \
--name $AGW_CERT_NAME \
--vault-name=$KV_NAME \
--query=sid \
--output=tsv 2>null)

if [ -z "$AGW_CERT_SECRET_ID"]
then
  # Create a new certificate in Azure Key Vault to be used by the Application Gateway
  az keyvault certificate create \
  --name=$AGW_CERT_NAME \
  --policy=@./policy.json \
  --vault-name=$KV_NAME

  # Add pause to allow for cert to fully be created
  sleep 20

  # Get the certificate secret id
  AGW_CERT_SECRET_ID=$(az keyvault certificate show \
  --name=$AGW_CERT_NAME \
  --vault-name=$KV_NAME \
  --query=sid \
  --output=tsv)
fi

# Remove the version so Application Gateway always pulls the most recent cert
AGW_CERT_SECRET_ID=$(echo $AGW_CERT_SECRET_ID | sed 's/\/[^/]*$//')

# Write the result to output
RESULT=$(cat << EOF
{
  "CERT_SECRET": "$AGW_CERT_SECRET_ID"
}
EOF
)

# Send result to output
echo $RESULT > $AZ_SCRIPTS_OUTPUT_PATH