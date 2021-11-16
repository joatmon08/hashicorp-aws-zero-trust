#!/bin/bash

mkdir -p /config

sed -i "s~AWS_IAM_ROLE~${AWS_IAM_ROLE}~g" /vault-agent/agent.hcl
sed -i "s~CONFIG_FILE_NAME~${CONFIG_FILE_NAME}~g" /vault-agent/agent.hcl
echo ${CONFIG_FILE_TEMPLATE} | base64 -d > /vault-agent/${CONFIG_FILE_NAME}

vault agent -config /vault-agent/agent.hcl