FROM alpine:3.22.2

RUN apk add --no-cache nginx \
	&& mkdir -p /run/nginx /var/www/html /var/cache/nginx /var/log/nginx \
	&& chown -R nginx:nginx /run/nginx /var/www/html /var/cache/nginx /var/log/nginx \
	&& rm -f /etc/nginx/http.d/default.conf

COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]
