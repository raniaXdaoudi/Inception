FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx openssl curl \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -f /etc/nginx/sites-enabled/default \
	&& rm -f /etc/nginx/sites-available/default \
	&& mkdir -p /var/www/html \
	&& chown -R www-data:www-data /var/www/html

COPY conf/main-nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf
COPY conf/nginx.crt /etc/nginx/nginx.crt
COPY conf/nginx.key /etc/nginx/nginx.key

# Configure permissions
RUN chmod 600 /etc/nginx/nginx.key \
	&& chmod 644 /etc/nginx/nginx.crt \
	&& chmod 644 /etc/nginx/conf.d/default.conf \
	&& chown -R www-data:www-data /etc/nginx/nginx.*

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 443

CMD ["/init.sh"]
