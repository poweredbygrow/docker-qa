FROM cypress/base:10

USER root
ENV CHROME_VERSION 84.0.4147.89-1
ENV FIREFOX_VERSION 78.0
ENV CLOUD_SDK_VERSION=275.0.0
RUN node --version

RUN apt-get update \
  && apt-get install -y --no-install-recommends apt-transport-https
RUN export CLOUD_SDK_REPO="cloud-sdk-stretch" \
  && echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
  && apt-get update \
  && apt-get install -y --no-install-recommends google-cloud-sdk=${CLOUD_SDK_VERSION}-0 

# install Firefox browser
RUN \
  wget -O ~/FirefoxSetup.tar.bz2 "https://download.mozilla.org/?product=firefox-${FIREFOX_VERSION}&os=linux64" && \
  tar xjf ~/FirefoxSetup.tar.bz2 -C /opt/ && \
  mkdir /usr/lib/firefox && \
  ln -s /opt/firefox/firefox /usr/bin/firefox

# install Chrome browser
RUN \
  wget --no-check-certificate https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}_amd64.deb && \
  dpkg -i google-chrome-stable_${CHROME_VERSION}_amd64.deb || apt -y -f install && \
  rm google-chrome-stable_${CHROME_VERSION}_amd64.deb;

# "fake" dbus address to prevent errors
# https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

# Add zip utility - it comes in very handy
RUN apt-get update && apt-get install -y zip

# versions of local tools
RUN node -v
RUN npm -v
RUN yarn -v
RUN google-chrome --version
RUN zip --version
RUN git --version

# a few environment variables to make NPM installs easier
# good colors for most applications
ENV TERM xterm
# avoid million NPM install messages
ENV npm_config_loglevel warn
# allow installing when the main user is root
ENV npm_config_unsafe_perm true
