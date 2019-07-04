FROM rocker/tidyverse:3.6.0@sha256:8e313b3a30bad31ad62d3920caee2061755bef91f117f453ced29df4c022a87e

ENV npm_version=6.9.0
RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    curl \
    gnupg && \
  curl -sL https://deb.nodesource.com/setup_11.x | bash - && \
  apt-get install -y --no-install-recommends \
    nodejs && \
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
