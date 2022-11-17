import shutil
import yaml
import sys

class constants:
    PREFIX='CONFIG_MIGRATION'
    GREEN='\033[0;32m'
    NC='\033[0m'

workingDir = sys.argv[1]

print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [2.py] Working dir: {workingDir}")
print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [2.py] copying default email templates")

templatesPath = f"{workingDir}/config/backend/email_templates"
dockerComposeTpl = f"{workingDir}/docker-compose.yml.tpl"
shutil.copytree(f"{workingDir}/bc2ip-tenant-config-migrations/assets/2", templatesPath)

print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [2.py] fixing docker-compose.yml.tpl syntax issues")
with open(dockerComposeTpl, 'r') as file:
    filedata = file.read()
    filedata = filedata.replace('{{databaseDataPath}}:/var/lib/postgresql/data', "'{{databaseDataPath}}:/var/lib/postgresql/data'")
    filedata = filedata.replace('{{encryptedFilesPath}}:/root/app/data', "'{{encryptedFilesPath}}:/root/app/data'")

    with open(dockerComposeTpl, 'w') as file:
        file.write(filedata)

print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [2.py] updating docker-compose.yml.tpl")
with open(dockerComposeTpl) as f:
    y = yaml.safe_load(f)
    y['services']['backend']['volumes'].append('./config/backend/email_templates:/root/app/dist/modules/mail/templates')
    with open(dockerComposeTpl, 'w') as file:
        file.write(yaml.safe_dump(y, default_flow_style=False, sort_keys=False))

print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [2.py] script finished")
