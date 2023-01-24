import shutil
import sys

class constants:
    PREFIX='CONFIG_MIGRATION'
    GREEN='\033[0;32m'
    NC='\033[0m'

workingDir = sys.argv[1]

print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [6.py] Working dir: {workingDir}")
print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [6.py] adding new notification email templates")

templatesPath = f"{workingDir}/config/backend/email_templates"
shutil.copytree(f"{workingDir}/bc2ip-tenant-config-migrations/assets/6", templatesPath, dirs_exist_ok=True)


print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [6.py] script finished")
