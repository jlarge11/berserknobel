#!/bin/bash

eval "$(jq -r '@sh "domain=\(.site_name)"')"

cert=$(aws acm request-certificate --domain-name $domain)

cert_arn=$(echo $cert | jq -r ".CertificateArn")

jq -n --arg cert_arn "$cert_arn" '{"CertificateArn":$cert_arn}'
