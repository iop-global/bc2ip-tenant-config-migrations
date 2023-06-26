import shutil
import sys

class constants:
    PREFIX='CONFIG_MIGRATION'
    GREEN='\033[0;32m'
    NC='\033[0m'

workingDir = sys.argv[1]

print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [7.py] Working dir: {workingDir}")
print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [7.py] changing tools'repo...")

dockerComposeTpl = f"{workingDir}/docker-compose.yml.tpl"

with open(dockerComposeTpl, 'r') as file:
    filedata = file.read()
    filedata = filedata.replace('europe-west3-docker.pkg.dev/iop-tresor/tresor-tools/webapp:latest', 'europe-west3-docker.pkg.dev/iop-tresor/tresor-tools/pwa:latest')

    with open(dockerComposeTpl, 'w') as file:
        file.write(filedata)


print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [7.py] script finished")
