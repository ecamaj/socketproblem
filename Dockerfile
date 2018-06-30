FROM ubuntu:16.04

MAINTAINER Eduard Camaj

RUN ln -snf /bin/bash /bin/sh
RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ precise-updates main restricted" | tee -a /etc/apt/sources.list.d/precise-updates.list

# update packages
RUN apt-get update && apt-get --yes upgrade && apt-get --yes install software-properties-common python-software-properties && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# za nginx
RUN add-apt-repository -y ppa:nginx/stable

# update packages and install required packages
# important ones: supervisord, nginx
RUN apt-get update  \
    && apt-get install -y  \
        build-essential \
        ca-certificates \
        gcc \
        git \
        logrotate \
        rsyslog \
        wget \
        curl libcurl3 libcurl3-dev \
        libssl-dev libffi-dev locales \
        libpq-dev \
        libffi6 libffi-dev \
        make \
        mercurial \
        pkg-config \
        vim \
        ssh \
        supervisor \
        nginx \
        python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# uwsgi
RUN pip3 install uwsgi==2.0.17 && pip3 install uwsgitop

ENV TZ=Europe/Zagreb
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# potrebno za UWSGITOP
ENV TERM=linux
ENV TERMINFO=/etc/terminfo

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

# broj procesa za UWSGI
ENV PROCESSES=1

RUN touch /var/log/cron.log
RUN mkdir /var/log/uwsgi && mkdir /home/app

ADD requirements.txt /home/app/requirements.txt
RUN pip3 install -r /home/app/requirements.txt

ADD logging.conf /home/app/
ADD nginx.conf /home/app/
ADD supervisord.conf /home/app/
ADD uwsgi.ini /home/app/
ADD uwsgi_params /home/app/
ADD wsgi.py /home/app/
ADD nonwsgi.py /home/app/

RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /home/app/nginx.conf /etc/nginx/sites-enabled/app.conf

WORKDIR /home/app

EXPOSE 80 443

HEALTHCHECK --interval=60s --timeout=10s --start-period=60s \
    CMD curl -f http://127.0.0.1/ || exit 1

CMD ["supervisord", "-n", "-c", "/home/app/supervisord.conf"]
