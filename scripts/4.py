import sys
import json

class constants:
    PREFIX='CONFIG_MIGRATION'
    GREEN='\033[0;32m'
    NC='\033[0m'

workingDir = sys.argv[1]

print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [4.py] Working dir: {workingDir}")
print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [4.py] adding apiPath to config/backend/config.json.tpl")
print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [4.py] switching mode from development to prod in config/backend/config.json.tpl")
print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [4.py] adding accessToken & refreshToken settings to config/backend/config.json.tpl")
templatePath=f"{workingDir}/config/backend/config.json.tpl"

with open(templatePath, 'r') as tplRead:
    template = tplRead.read()
    template = template.replace('{{adminEmails}}', '"{{adminEmails}}"')
    template = template.replace('{{mailingTls}}', '"{{mailingTls}}"')
    template = template.replace('{{mailingRejectUnauthorized}}', '"{{mailingRejectUnauthorized}}"')
    with open(templatePath, 'w') as tplWrite:
        tplWrite.write(template)

with open(templatePath, 'r') as tplRead:
    j = json.loads(tplRead.read())
    j['apiPath'] = '/api'
    j['mode'] = 'prod'
    jwtToken = j['auth']['jwt']['secret']
    del j['auth']['jwt']
    j['auth']['accessToken'] = { 'secret': jwtToken, 'signOptions': { 'expiresIn': '10m' } };
    j['auth']['refreshToken'] = { 'secret': jwtToken, 'signOptions': { 'expiresIn': '60m' } };

    with open(templatePath, 'w') as tplWrite:
        tplWrite.seek(0)
        # this is needed to keep the properties' order
        json.dump({
            'mode': j['mode'],
            'apiPath': j['apiPath'],
            'auth': {
                'admins': j['auth']['admins'],
                'encryptionKey': j['auth']['encryptionKey'],
                'accessToken': j['auth']['accessToken'],
                'refreshToken': j['auth']['refreshToken'],
                'magicLink': j['auth']['magicLink'],
            },
            'console': j['console'],
            'apiBaseUrl': j['apiBaseUrl'],
            'frontEndUrl': j['frontEndUrl'],
            'mailer': j['mailer'],
        }, tplWrite, indent=2)
        tplWrite.truncate()

with open(templatePath, 'r') as tplRead:
    template = tplRead.read()
    template = template.replace('"{{adminEmails}}"', '{{adminEmails}}')
    template = template.replace('"{{mailingTls}}"', '{{mailingTls}}')
    template = template.replace('"{{mailingRejectUnauthorized}}"', '{{mailingRejectUnauthorized}}')
    with open(templatePath, 'w') as tplWrite:
        tplWrite.write(template)

print(f"{constants.GREEN}[{constants.PREFIX}]:{constants.NC} [4.py] script finished")
