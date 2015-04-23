FROM docker-reg.misdepartment.com/rbemail-baseimage

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Remove folders if they exist
RUN rm -rf /home/app/rbemail && mkdir -p /home/app/rbemail && rm -rf /etc/nginx/sites-enabled/* && rm -f /etc/service/nginx/down
WORKDIR /home/app/rbemail

ADD . /home/app/rbemail

ADD config/instance_profiles/app/docker/nginx.conf /etc/nginx/sites-enabled/rbemail.conf
ADD config/instance_profiles/app/docker/docker-env.conf /etc/nginx/main.d/rbemail.conf

RUN chown app:app /home/app -R

RUN gem install bundler && su app -c 'bundle install --path /home/app/bundle --without development test'

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
