FROM rocker/tidyverse:3.5.2

ENV npm_version=6.4.1
RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    curl \
    gnupg && \
  curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - && \
  apt-get install -y --no-install-recommends \
    nodejs \
    npm && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  npm install npm@${npm_version} -g && \
  rm -rf /tmp/npm-*

ARG GITHUB_PAT

RUN set -x && \
  echo "GITHUB_PAT=$GITHUB_PAT" >> /usr/local/lib/R/etc/Renviron

RUN set -x && \
  install2.r --error \
    jsonlite \
    processx \
    rcmdcheck \
    reprex \
    usethis && \
  rm -rf /tmp/downloaded_packages/ /tmp/*.rds
