#!/bin/bash

set -e
PREFIX="CONFIG_MIGRATION"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}[$PREFIX]:${NC} Running config migration scripts..."

currentVersion=0

if [ ! -f "version" ]; then
    echo -e "${YELLOW}[$PREFIX]:${NC} version file does not exist, creating a new one, starting with '0'"
    echo "0" > version
else
    currentVersion=$(cat version)
fi

echo -e "${GREEN}[$PREFIX]:${NC} current config version '${currentVersion}'"

for f in $(ls -v ./migration/scripts/*.sh)
do
    upComingVersion=${f/\.sh/""}
    upComingVersion=${upComingVersion/"./migration/scripts/"/""}
    if (( "$upComingVersion" <= "$currentVersion" )); then
        echo -e "${GREEN}[$PREFIX]:${NC} $f: already run, skipping"
        continue
    fi
    echo -e "${GREEN}[$PREFIX]:${NC} $f: running..."
    /bin/bash $f
    echo $upComingVersion>version
    echo -e "${GREEN}[$PREFIX]:${NC} $f: - OK"
done

echo -e "${GREEN}[$PREFIX]:${NC} All is DONE.\n"
