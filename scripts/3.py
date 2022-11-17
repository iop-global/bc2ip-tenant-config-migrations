import sys

class constants:
    PREFIX='CONFIG_MIGRATION'
    GREEN='\033[0;32m'
    NC='\033[0m'

workingDir = sys.argv[1]

print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [3.py] Working dir: {workingDir}")
print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [3.py] fixing mailingTls and mailingRejectUnauthorized in config/backend/config.json.tpl")
templatePath=f"{workingDir}/config/backend/config.json.tpl"

with open(templatePath, 'r') as tplRead:
    template = tplRead.read()
    template = template.replace('"{{mailingTls}}"', '{{mailingTls}}')
    template = template.replace('"{{mailingRejectUnauthorized}}"', '{{mailingRejectUnauthorized}}')

    with open(templatePath, 'w') as tplWrite:
        tplWrite.write(template)

print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [3.py] script finished")
