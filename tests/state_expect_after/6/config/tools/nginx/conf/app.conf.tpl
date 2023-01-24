upstream up_webservice {
    server sdk-webservice:4201;
}

server {
    listen {{portsTools}};
    server_name tresor-tools-tenant;
    server_tokens off;
    client_max_body_size 50M;

    root /usr/share/nginx/html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /index.html {
        add_header Cache-Control no-cache;
    }

    location =/settings.json {
        alias /usr/share/nginx/html/tenant-config.json;
    }

    location =/tenant-logo.png {
        alias /usr/share/nginx/html/tenant-logo.png;
    }

    location /webservice/ {
        proxy_redirect off;
        proxy_set_header Host $host;
        # THE SLASH IN THE END IS REQUIRED! SEE: https://stackoverflow.com/questions/32542282/how-do-i-rewrite-urls-in-a-proxy-response-in-nginx
        proxy_pass http://up_webservice/;
    }
}