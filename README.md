# bc2ip Tenant Config Migrations

## What is bc2ip?

An easy-to-use white-label blockchain application for enterprises, innovators and IP attorneys for all product development and IP processes and to meet the requirements of the Trade Secrets Regulation (EU 2016/943).

## Config Migrations

This repository contains migration scripts for tenant installations.

## Migrations

### 1.py

Initializes the congiration migrations environment. Creates a `version` file with a content of `1`.

### 2.py

- Creates a directory with email templates at `config/backend/email_templates`. The templates here are used when sending out mails.
- Fixes two syntax errors in the `docker-compose.yml.tpl` template:
  - Replaces `{{databaseDataPath}}:/var/lib/postgresql/data` to `'{{databaseDataPath}}:/var/lib/postgresql/data'`.
  - Replaces `{{encryptedFilesPath}}:/root/app/data` to `'{{encryptedFilesPath}}:/root/app/data'`.
- Adds a new entry in `docker-compose.yml.tpl` to `.services.backend.volumes`: `./config/backend/email_templates:/root/app/dist/modules/mail/templates`.
- Bumps `version` file to `2`. 

### 3.py

- Fixes some properties in `config/backend/config.json.tpl` as those were expected to be handled as booleans, but were strings:
  - `"rejectUnauthorized": "{{mailingRejectUnauthorized}}",` -> `"rejectUnauthorized": {{mailingRejectUnauthorized}},`
  - `"secure": "{{mailingTls}}",` -> `"secure": {{mailingTls}},`

### 4.py

- Switches backend service's mode from `development` to `prod`.
- Adds `"apiPath": "/api"` to `config/backend/config.json.tpl`.
- Adds `auth.refreshToken` to `config/backend/config.json.tpl`.
- Renames `auth.jwt` to `auth.accessToken` in `config/backend/config.json.tpl`.

### 5.py

- Updates default authentication email templates to include magic link expiratation date
- Adds default project change email templates

### 6.py

- Adds new notification email templates:
  - User added to client: `added-to-client.hbs`
  - User removed from client: `removed-from-client.hbs`
  - Device added: `device-added.hbs`
  - Devire removed: `device-removed.hbs`
  - Project membership changed: `project-membership-changed.hbs`

### 7.py

- Use new registry for the new version of tools.

## Tests

### Requirements

- Python 3 PIP

### Usage

Run these commands in the `tests`.

```bash
$ pip3 install -r requirements.txt
```

```bash
$ python3 -m unittest
```
