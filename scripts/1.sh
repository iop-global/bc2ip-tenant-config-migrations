#!/bin/bash

set -e
PREFIX="CONFIG_MIGRATION"
GREEN='\033[0;32m'
NC='\033[0m'

currentBackendConfig=$(cat config/backend/config.json.tpl)
currentBackendConfig=${currentBackendConfig/"{{adminEmails}}"/"\"{{adminEmails}}\""}
accessTokenSecret=$(echo $currentBackendConfig | jq -r '.auth.jwt.secret')
refreshTokenSecret=$(echo $accessTokenSecret | sed 's/./&\n/g' | shuf | tr -d "\n")

echo -e "${GREEN}[$PREFIX]:${NC} - Adding new token configuration"
newBackendConfig=$(echo $currentBackendConfig | jq '.auth.accessToken += {"secret":"'$accessTokenSecret'", "signOptions":{"expiresIn":"10m"}}')
newBackendConfig=$(echo $newBackendConfig | jq '.auth.refreshToken += {"secret":"'$refreshTokenSecret'", "signOptions":{"expiresIn":"60m"}}')

echo -e "${GREEN}[$PREFIX]:${NC} - Removing old token configuration"
newBackendConfig=$(echo $newBackendConfig | jq 'del(.auth.jwt)')

echo -e "${GREEN}[$PREFIX]:${NC} - Changing development mode to prod"
newBackendConfig=$(echo $newBackendConfig | jq 'del(.mode)')
newBackendConfig=$(echo $newBackendConfig | jq '.mode += "prod"')

echo -e "${GREEN}[$PREFIX]:${NC} - Writing changes"
echo "${newBackendConfig/"\"{{adminEmails}}\""/"{{adminEmails}}"}" > config/backend/config.json.tpl
