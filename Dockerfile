FROM python:3.4

RUN apt-get update -y 
RUN apt-get upgrade -y 
RUN apt-get install -y git build-essential libcurl4-gnutls-dev libgnutls28-dev python3-dev apache2 php5 libapache2-mod-php5 supervisor redis-server sudo && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/ /tmp/ /var/tmp/*
	
RUN git clone https://github.com/certtools/intelmq.git /tmp/intelmq
WORKDIR /tmp/intelmq

RUN pip3 install -r REQUIREMENTS && pip3 install . 
RUN mv /opt/intelmq/etc/examples/*.conf /opt/intelmq/etc/
COPY config/* /opt/intelmq/etc/

RUN useradd -d /opt/intelmq -U -s /bin/bash intelmq && \
    mkdir -p /opt/intelmq/var/log && \
    touch /opt/intelmq/var/log/intelmqctl.log && \
    chmod -R 0770 /opt/intelmq && \
    chown intelmq.intelmq /opt/intelmq/var/log/intelmqctl.log && \
    chown -R intelmq.intelmq /opt/intelmq

RUN   git clone https://github.com/certtools/intelmq-manager.git /tmp/intelmq-manager && \
    cp -R /tmp/intelmq-manager/intelmq-manager/* /var/www/html/ && \
    chown -R www-data.www-data /var/www/html/ && \
    usermod -a -G intelmq www-data
   
RUN echo "www-data ALL=(intelmq) NOPASSWD: /usr/local/bin/intelmqctl" > /etc/sudoers.d/intelmq && \
    chmod 0440 /etc/sudoers.d/intelmq

COPY intelmq_redis.conf /etc/redis/intelmq_redis.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY pipeline.js /var/www/html/js/pipeline.js

EXPOSE 80
EXPOSE 443

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
