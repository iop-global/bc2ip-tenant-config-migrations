{
  "mode": "development",
  "auth": {
    "admins": {{adminEmails}},
    "encryptionKey": "a_key",
    "jwt": {
      "secret": "a_secret",
      "signOptions": {
        "expiresIn": "10m"
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