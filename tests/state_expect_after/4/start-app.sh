#!/bin/bash

set -e
RED='\033[0;31m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
BROWN='\033[0;33m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "\n"

# CHECKING DEPENDENCIES
if ! command -v curl &> /dev/null
then
    echo -e "${RED}[ERROR]:${NC} curl not found. Please install all the commandline dependencies: curl, jq, wget, git, python3"
    exit 1
fi

if ! command -v wget &> /dev/null
then
    echo -e "${RED}[ERROR]:${NC} wget not found. Please install all the commandline dependencies: curl, jq, wget, git, python3"
    exit 1
fi

if ! command -v jq &> /dev/null
then
    echo -e "${RED}[ERROR]:${NC} jq not found. Please install all the commandline dependencies: curl, jq, wget, git, python3"
    exit 1
fi

if ! command -v git &> /dev/null
then
    echo -e "${RED}[ERROR]:${NC} git not found. Please install all the commandline dependencies: curl, jq, wget, git, python3"
    exit 1
fi

if ! command -v python3 &> /dev/null
then
    echo -e "${RED}[ERROR]:${NC} git not found. Please install all the commandline dependencies: curl, jq, wget, git, python3"
    exit 1
fi

if [ ! -f "master-configuration.json" ]; then
    echo -e "${RED}[ERROR]:${NC} master-configuration.json does not exist."
    exit 1
fi

migrationsRepo=bc2ip-tenant-config-migrations

if [ -d "$migrationsRepo" ];
then
    cd $migrationsRepo
    git fetch
    git reset --hard origin/master
    cd ..
else
    git clone https://github.com/iop-global/bc2ip-tenant-config-migrations.git
fi

./$migrationsRepo/run.sh

consoleBaseUrl=https://dev-console.bc2ip.com/api/apikey
apiKey=AN_API_KEY

queryUrl() {
    statusCode=$(curl -I -s -X 'GET' $consoleBaseUrl$1 -H 'accept: application/json' -H "x-api-key: $apiKey" 2> /dev/null | head -n 1 | cut -d$' ' -f2)

    if [ $statusCode -ne 200 ]; then
        echo -e "${RED}[ERROR]:${NC} API Error. Got back HTTP $statusCode for URL: $consoleBaseUrl$1"
        exit
    fi

    response=$(curl -s -X 'GET' $consoleBaseUrl$1 -H 'accept: application/json' -H "x-api-key: $apiKey")
    echo $response
}

# QUERY DOCKER SETTINGS
echo -e "${PURPLE}Script settings${NC}"
echo -e "  - Console API URL: $consoleBaseUrl"
echo -e "  - API Key:         $apiKey\n"

echo -e "${PURPLE}1. Querying docker settings from /auth/docker...${NC}"
dockerResponse=$(queryUrl "/auth/docker")
registryUrl=$(echo $dockerResponse | jq -r '.registryUrl')
user=$(echo $dockerResponse | jq -r '.user')
password=$(echo $dockerResponse | jq -r '.password')
echo "  - Registry: $registryUrl"
echo "  - User:     $user"
echo "  - Password: ***"
echo -e "  OK\n"

# QUERY WHITELABEL PROPS
echo -e "${PURPLE}2. Querying whitelabel properties from /whitelabel/props...${NC}"
whitelabelPropsResponse=$(queryUrl "/whitelabel/props")
adminEmails=$(echo $whitelabelPropsResponse | jq -r -c '.adminEmails')
webappPrimaryColor=$(echo $whitelabelPropsResponse | jq -r '.webapp.colors.primary')
webappName=$(echo $whitelabelPropsResponse | jq -r '.webapp.name')
toolsPrimaryColor=$(echo $whitelabelPropsResponse | jq -r '.tools.colors.primary')
toolsName=$(echo $whitelabelPropsResponse | jq -r '.tools.name')
echo "  - Admin emails:         $adminEmails"
echo "  - Webapp primary color: $webappPrimaryColor"
echo "  - Webapp brand name:    $webappName"
echo "  - Tools primary color:  $toolsPrimaryColor"
echo "  - Tools brand name:     $toolsName"
echo -e "  OK\n"

backendConfig=$(<config/backend/config.json.tpl)
updatedBackendConfig="${backendConfig//\{\{adminEmails\}\}/"$adminEmails"}"

webappTenantConfig=$(<config/webapp/nginx/tenant/tenant-config.json.tpl)
updatedWebappTenantConfig="${webappTenantConfig//\{\{mainHexColor\}\}/"$webappPrimaryColor"}"
updatedWebappTenantConfig="${updatedWebappTenantConfig//\{\{brandName\}\}/"$webappName"}"

toolsTenantConfig=$(<config/tools/nginx/tenant/tenant-config.json.tpl)
updatedToolsTenantConfig="${toolsTenantConfig//\{\{mainHexColor\}\}/"$toolsPrimaryColor"}"
updatedToolsTenantConfig="${updatedToolsTenantConfig//\{\{brandName\}\}/"$toolsName"}"

echo -e "${PURPLE}3. Downloading whitelabel logo from /whitelabel/logo...${NC}"
mkdir -p tmp
wget --header='accept: application/json' --header="x-api-key: $apiKey" $consoleBaseUrl/whitelabel/logo -q -O tmp/tenant-logo.png
wget --header='accept: application/json' --header="x-api-key: $apiKey" $consoleBaseUrl/whitelabel/logo -q -O config/webapp/nginx/tenant/tenant-logo.png
echo -e "  OK\n"

echo -e "${PURPLE}4. Reading master configuration...${NC}"
masterCfg=$(<master-configuration.json)
tenantName=$(echo $masterCfg | jq -r -c '.tenantName.value')
appBaseUrl=$(echo $masterCfg | jq -r -c '.appBaseUrl.value')
toolsBaseUrl=$(echo $masterCfg | jq -r -c '.toolsBaseUrl.value')
portsWebapp=$(echo $masterCfg | jq -r -c '.ports.webapp.value')
portsTools=$(echo $masterCfg | jq -r -c '.ports.tools.value')
databaseBackupPath=$(echo $masterCfg | jq -r -c '.backupLocations.databaseDataPath.value')
encryptedFilesBackupPath=$(echo $masterCfg | jq -r -c '.backupLocations.encryptedFilesPath.value')
mailHost=$(echo $masterCfg | jq -r -c '.mailing.host.value')
mailPort=$(echo $masterCfg | jq -r -c '.mailing.port.value')
mailIsScure=$(echo $masterCfg | jq -r -c '.mailing.secure.value')
mailRejectUnauthorizedTls=$(echo $masterCfg | jq -r -c '.mailing.rejectUnauthorizedTls.value')
mailSmtpUser=$(echo $masterCfg | jq -r -c '.mailing.smtpUser.value')
mailSmtpPassword=$(echo $masterCfg | jq -r -c '.mailing.smtpPassword.value')
mailFrom=$(echo $masterCfg | jq -r -c '.mailing.from.value')

echo -e "  - Tenant name:         $([ -z "$tenantName" ] && echo "${RED}!!!${NC}" || echo $tenantName)"
echo -e "  - App base URL:        $([ -z "$appBaseUrl" ] && echo "${RED}!!!${NC}" || echo $appBaseUrl)"
echo -e "  - Tools base URL:      $([ -z "$toolsBaseUrl" ] && echo "${RED}!!!${NC}" || echo $toolsBaseUrl)"
echo -e "  - Ports"
echo -e "    - Webapp:            $([ -z "$portsWebapp" ] && echo "${RED}!!!${NC}" || echo $portsWebapp)"
echo -e "    - Tools:             $([ -z "$portsTools" ] && echo "${RED}!!!${NC}" || echo $portsTools)"
echo -e "  - Backup"
echo -e "    - Path for database: $([ -z "$databaseBackupPath" ] && echo "${YELLOW}None. Using Docker volume: bc2ip-database${NC}" || echo $databaseBackupPath)"
echo -e "    - Path for files:    $([ -z "$encryptedFilesBackupPath" ] && echo "${YELLOW}None. Using Docker volume: bc2ip-app${NC}" || echo $encryptedFilesBackupPath)"
echo -e "  - Mailing"
echo -e "    - Host:              $([ -z "$mailHost" ] && echo "${RED}!!!${NC}" || echo $mailHost)"
echo -e "    - Port:              $([ -z "$mailPort" ] && echo "${RED}!!!${NC}" || echo $mailPort)"
echo -e "    - Secure:            $([ -z "$mailIsScure" ] && echo "${RED}!!!${NC}" || echo $mailIsScure)"
echo -e "    - Reject unauth TLS: $([ -z "$mailRejectUnauthorizedTls" ] && echo "${RED}!!!${NC}" || echo $mailRejectUnauthorizedTls)"
echo -e "    - SMTP user:         $([ -z "$mailSmtpUser" ] && echo "${RED}!!!${NC}" || echo $mailSmtpUser)"
echo -e "    - SMTP password:     $([ -z "$mailSmtpPassword" ] && echo "${RED}!!!${NC}" || echo $mailSmtpPassword)"
echo -e "    - Mail from:         $([ -z "$mailFrom" ] && echo "${RED}!!!${NC}" || echo $mailFrom)"

echo -e "\n${PURPLE}----------------------------------------------------${NC}"
echo -e "${PURPLE}######## Please confirm BC2IP configuration ########${NC}\n"
echo -e "${PURPLE}Are you sure you'd like to start BC2IP with these settings?${NC}"

while true; do

read -e -p "(yes/no) " yn

case $yn in
	yes ) break;;
	no ) exit;;
esac

done

updatedBackendConfig="${updatedBackendConfig//\{\{baseUrl\}\}/"$appBaseUrl"}"
updatedBackendConfig="${updatedBackendConfig//\{\{baseUrl\}\}/"$appBaseUrl"}"
updatedBackendConfig="${updatedBackendConfig//\{\{mailingHost\}\}/"$mailHost"}"
updatedBackendConfig="${updatedBackendConfig//\{\{mailingPort\}\}/"$mailPort"}"
updatedBackendConfig="${updatedBackendConfig//\{\{mailingTls\}\}/"$mailIsScure"}"
updatedBackendConfig="${updatedBackendConfig//\{\{mailingUser\}\}/"$mailSmtpUser"}"
updatedBackendConfig="${updatedBackendConfig//\{\{mailingPassword\}\}/"$mailSmtpPassword"}"
updatedBackendConfig="${updatedBackendConfig//\{\{mailingRejectUnauthorized\}\}/"$mailRejectUnauthorizedTls"}"
updatedBackendConfig="${updatedBackendConfig//\{\{mailingFrom\}\}/"$mailFrom"}"

toolsNginxConfig=$(cat config/tools/nginx/conf/app.conf.tpl)
updatedToolsNginxConfig="${toolsNginxConfig//\{\{portsTools\}\}/"$portsTools"}"

webappNginxConfig=$(<config/webapp/nginx/conf/app.conf.tpl)
updatedWebappNginxConfig="${webappNginxConfig//\{\{portsWebapp\}\}/"$portsWebapp"}"

updatedWebappTenantConfig="${updatedWebappTenantConfig//\{\{mainHexColor\}\}/"$webappPrimaryColor"}"
updatedWebappTenantConfig="${updatedWebappTenantConfig//\{\{brandName\}\}/"$webappName"}"

updatedToolsTenantConfig="${updatedToolsTenantConfig//\{\{mainHexColor\}\}/"$toolsPrimaryColor"}"
updatedToolsTenantConfig="${updatedToolsTenantConfig//\{\{brandName\}\}/"$toolsName"}"

dockerCompose=$(cat docker-compose.yml.tpl)
updatedDockerCompose="${dockerCompose//\{\{tenantName\}\}/"$tenantName"}"
updatedDockerCompose="${updatedDockerCompose//\{\{databaseDataPath\}\}/"$([ -z "$databaseBackupPath" ] && echo "bc2ip-database" || echo $databaseBackupPath)"}"
updatedDockerCompose="${updatedDockerCompose//\{\{encryptedFilesPath\}\}/"$([ -z "$encryptedFilesBackupPath" ] && echo "bc2ip-app" || echo $encryptedFilesBackupPath)"}"
updatedDockerCompose="${updatedDockerCompose//\{\{baseUrl\}\}/"$appBaseUrl"}"
updatedDockerCompose="${updatedDockerCompose//\{\{portsWebapp\}\}/"$portsWebapp"}"
updatedDockerCompose="${updatedDockerCompose//\{\{toolsBaseUrl\}\}/"$toolsBaseUrl"}"
updatedDockerCompose="${updatedDockerCompose//\{\{portsTools\}\}/"$portsTools"}"

echo -e "${PURPLE}4. Updating configuration...${NC}"
echo "$updatedDockerCompose">docker-compose.yml
echo -e "  - docker-compose.yml OK"

echo "$updatedBackendConfig">config/backend/config.json
echo -e "  - config/backend/config.json OK"

echo "$updatedToolsNginxConfig">config/tools/nginx/conf/app.conf
echo -e "  - config/tools/nginx/conf/app.conf OK"

echo "$updatedWebappNginxConfig">config/webapp/nginx/conf/app.conf
echo -e "  - config/webapp/nginx/conf/app.conf OK"

echo "$updatedWebappTenantConfig">config/webapp/nginx/tenant/tenant-config.json
echo -e "  - config/webapp/nginx/tenant/tenant-config.json OK"

echo "$updatedToolsTenantConfig">config/tools/nginx/tenant/tenant-config.json
echo -e "  - config/tools/nginx/tenant/tenant-config.json OK"

cp tmp/tenant-logo.png config/webapp/nginx/tenant/tenant-logo.png
echo -e "  - config/webapp/nginx/tenant/tenant-logo.png OK"
cp tmp/tenant-logo.png config/tools/nginx/tenant/tenant-logo.png
echo -e "  - config/tools/nginx/tenant/tenant-logo.png OK"
echo -e "  OK\n"

echo -e "${PURPLE}5. Updating application Docker images...${NC}"
docker login -u $user -p $password $registryUrl
docker-compose pull backend
docker-compose pull webapp
docker-compose pull sdk-webservice
docker-compose pull tools
echo -e "${PURPLE}6. Restarting components if needed...${NC}"
docker-compose up -d

docker logout $registryUrl

echo -e "\n${GREEN}< BC2IP application has been started. >${NC}"
echo -e ' -------------------------------------'
echo -e '        \   ^__^'
echo -e '         \  (oo)\_______'
echo -e '            (__)\       )\/\'
echo -e '                ||----w |'
echo -e '                ||     ||'
