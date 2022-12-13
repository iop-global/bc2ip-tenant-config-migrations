{
  "mode": "prod",
  "apiPath": "/api",
  "auth": {
    "admins": {{adminEmails}},
    "encryptionKey": "a_key",
    "accessToken": {
      "secret": "a_secret",
      "signOptions": {
        "expiresIn": "10m"
      }
    },
    "refreshToken": {
      "secret": "a_secret",
      "signOptions": {
        "expiresIn": "60m"
      }
    },
    "magicLink": {
      "secret": "a_secret"
    }
  },
  "console": {
    "apiKey": "AN_API_KEY",
    "url": "https://dev-console.bc2ip.com/api"
  },
  "apiBaseUrl": "{{baseUrl}}/api",
  "frontEndUrl": "{{baseUrl}}",
  "mailer": {
    "transport": {
      "host": "{{mailingHost}}",
      "secure": {{mailingTls}},
      "port": "{{mailingPort}}",
      "auth": {
        "user": "{{mailingUser}}",
        "pass": "{{mailingPassword}}"
      },
      "tls": {
        "rejectUnauthorized": {{mailingRejectUnauthorized}}
      }
    },
    "defaults": {
      "from": "{{mailingFrom}}"
    }
  }
}