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

- Switces backend service's mode from `development` to `prod`.
- Adds `"apiPath": "/api"` to `config/backend/config.json.tpl`.
- Adds `auth.refreshToken` to `config/backend/config.json.tpl`.
- Renames `auth.jwt` to `auth.accessToken` in `config/backend/config.json.tpl`.

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
