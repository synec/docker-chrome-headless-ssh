FROM ubuntu:xenial
MAINTAINER Daniel Grabert <dg@indivirtuell.net>

RUN apt-get update --yes

RUN apt-get install --yes locales
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Install SSH server
RUN apt-get install --yes openssh-server
RUN mkdir /var/run/sshd
RUN sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config

# Install deps + add Chrome Stable + purge all the things
RUN apt-get install --yes  apt-transport-https ca-certificates curl gnupg  --no-install-recommends

# add chrome source to apt
RUN curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update --yes

# Prevent chrome self update
RUN touch /etc/default/google-chrome

# Install Chrome
RUN apt-get install --yes  google-chrome-stable --no-install-recommends

# Add Chrome as a user
RUN groupadd -r chrome && useradd -r -g chrome -G audio,video chrome
RUN printf "chrome\nchrome\n" | passwd chrome
RUN mkdir -p /home/chrome && chown -R chrome:chrome /home/chrome

RUN apt-get install -y supervisor vim

COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY sshd.conf /etc/supervisor/sshd.conf

RUN mkdir -p /var/log/supervisor

# apt cleanup
# RUN apt-get purge --auto-remove --allow-remove-essential --yes curl gnupg
RUN rm -rf /var/lib/apt/lists/*

# Expose port 9222
EXPOSE 9222
EXPOSE 22

CMD ["/usr/bin/supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]
