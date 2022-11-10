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