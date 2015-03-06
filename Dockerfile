FROM ubuntu:trusty
MAINTAINER Nathan Henderson <nate908@gmail.com>
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list && \

# Install php and nginx
  apt-get update && apt-get install -y \
  nginx php5 php5-fpm supervisor; \
 
# We need to add a config file for supervisor, so stop the service that was auto-started on intstall
  service supervisor stop; \

# nginx config
  sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf; \
  sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf; \
  echo "daemon off;" >> /etc/nginx/nginx.conf; \

# Edit the php5-fpm conf to point to our unix socket file
  sed -i -e '/listen = 127.0.0.1:9000/ s/127.0.0.1:9000/\/var\/run\/php5-fpm.sock/' /etc/php5/fpm/pool.d/www.conf; \

# Setup root web directory
  mkdir /var/www && \

# Add a phpinfo file 
  echo "<?php phpinfo(); ?>" > /var/www/phpinfo.php && \

# Change ownership of the www directory to the nginx user
  chown -R www-data:www-data /var/www; \

# Clean up
  apt-get clean; \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./nginx-site.conf /etc/nginx/sites-enabled/default
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Initialization and Startup Script
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

# private expose
EXPOSE 80

CMD ["/bin/bash", "/start.sh"]
