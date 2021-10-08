#!/bin/bash

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