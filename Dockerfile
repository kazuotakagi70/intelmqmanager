FROM python:3.4

RUN apt-get update -y 
RUN apt-get upgrade -y 
RUN apt-get install -y git build-essential libcurl4-gnutls-dev libgnutls28-dev python3-dev apache2 php5 libapache2-mod-php5 supervisor && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/ /tmp/ /var/tmp/*
	
RUN git clone https://github.com/certtools/intelmq.git /tmp/intelmq
WORKDIR /tmp/intelmq

RUN pip3 install -r REQUIREMENTS && pip3 install . 
RUN mv /opt/intelmq/etc/examples/*.conf /opt/intelmq/etc/
COPY config/* /opt/intelmq/etc/

RUN useradd -d /opt/intelmq -U -s /bin/bash intelmq && \
    chmod -R 0770 /opt/intelmq && \
    chown -R intelmq.intelmq /opt/intelmq

RUN   git clone https://github.com/certtools/intelmq-manager.git /tmp/intelmq-manager && \
    cp -R /tmp/intelmq-manager/intelmq-manager/* /var/www/html/ && \
    chown -R www-data.www-data /var/www/html/ && \
    usermod -a -G intelmq www-data && \
    echo "www-data ALL=(intelmq) NOPASSWD: /usr/local/bin/intelmqctl" >> /etc/sudoers

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80
EXPOSE 443

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
