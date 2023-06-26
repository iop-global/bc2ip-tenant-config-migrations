version: '3'
volumes:
  bc2ip-database:
    name: bc2ip-database
  bc2ip-app:
    name: bc2ip-app
services:
  db:
    image: postgres:14
    container_name: BC2IP-{{tenantName}}-database
    environment:
      POSTGRES_USER: tresor-tenant
      POSTGRES_PASSWORD: password
      POSTGRES_DB: tresor-tenant
    volumes:
    - '{{databaseDataPath}}:/var/lib/postgresql/data'
    networks:
    - tresor-tenant
    ports:
    - '5432'
  backend:
    image: europe-west3-docker.pkg.dev/iop-tresor/tresor-backend/app:latest
    container_name: BC2IP-{{tenantName}}-backend
    networks:
    - tresor-tenant
    ports:
    - '3000'
    volumes:
    - ./config/backend/config.json:/root/app/config.json
    - ./config/backend/.env:/root/app/.env
    - '{{encryptedFilesPath}}:/root/app/data'
    - ./config/backend/email_templates:/root/app/dist/modules/mail/templates
    depends_on:
    - db
  webapp:
    image: europe-west3-docker.pkg.dev/iop-tresor/tresor-webapp/app:latest
    container_name: BC2IP-{{tenantName}}-webapp
    restart: unless-stopped
    networks:
    - tresor-tenant
    volumes:
    - ./config/webapp/nginx/conf:/etc/nginx/conf.d
    - ./config/webapp/nginx/tenant/tenant-config.json:/usr/share/nginx/html/tenant-config.json
    - ./config/webapp/nginx/tenant/tenant-logo.png:/usr/share/nginx/html/tenant-logo.png
    environment:
    - DOCKER_serverUrl={{baseUrl}}/api
    - DOCKER_currentTenant={{baseUrl}}
    ports:
    - '{{portsWebapp}}:{{portsWebapp}}'
    depends_on:
    - backend
  sdk-webservice:
    image: europe-west3-docker.pkg.dev/iop-tresor/tresor-tools/sdk-service:latest
    container_name: BC2IP-{{tenantName}}-sdk-webservice
    restart: unless-stopped
    networks:
    - tresor-tenant
    environment:
    - hydraledgerNetwork=mainnet
    ports:
    - '4201'
  tools:
    image: europe-west3-docker.pkg.dev/iop-tresor/tresor-tools/pwa:latest
    container_name: BC2IP-{{tenantName}}-tools
    restart: unless-stopped
    networks:
    - tresor-tenant
    volumes:
    - ./config/tools/nginx/conf:/etc/nginx/conf.d
    - ./config/tools/nginx/tenant/tenant-config.json:/usr/share/nginx/html/tenant-config.json
    - ./config/tools/nginx/tenant/tenant-logo.png:/usr/share/nginx/html/tenant-logo.png
    environment:
    - DOCKER_currentTenant={{toolsBaseUrl}}
    - DOCKER_webService={{toolsBaseUrl}}/webservice
    - DOCKER_hydraledgerNetwork=mainnet
    ports:
    - '{{portsTools}}:{{portsTools}}'
    depends_on:
    - sdk-webservice
networks:
  tresor-tenant: null
