FROM nginx:latest

COPY gen_certs.sh /usr/local/bin/gen_certs.sh

RUN chmod +x /usr/local/bin/gen_certs.sh

VOLUME [ "/etc/nginx/certs", "/var/log/nginx", "/etc/nginx/nginx.conf", "/etc/nginx/conf.d" ]

EXPOSE 8000 8001

ENTRYPOINT ["/usr/local/bin/gen_certs.sh"]

CMD ["nginx", "-g", "daemon off;"]


