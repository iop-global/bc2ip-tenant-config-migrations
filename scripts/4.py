import sys

class constants:
    PREFIX='CONFIG_MIGRATION'
    GREEN='\033[0;32m'
    NC='\033[0m'

workingDir = sys.argv[1]

print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [4.py] Working dir: {workingDir}")
print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [4.py] adding apiPath to config/backend/config.json.tpl")
print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [4.py] switching mode from development to prod in config/backend/config.json.tpl")
templatePath=f"{workingDir}/config/backend/config.json.tpl"

with open(templatePath, 'r') as tplRead:
    template = tplRead.read()
    template = template.replace('"mode": "development",', '"mode": "prod",\n  "apiPath": "/api",')

    with open(templatePath, 'w') as tplWrite:
        tplWrite.write(template)

print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [4.py] script finished")
