FROM rocker/tidyverse:3.5.1

RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    wget && \
  curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - && \
  apt-get install -y --no-install-recommends \
    nodejs \
    npm && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENV TEXTLINT_VERSION=11.0.0
RUN set -x && \
  npm install -g textlint@${TEXTLINT_VERSION} && \
  npm install -g \
    textlint-rule-preset-jtf-style \
    textlint-rule-max-ten \
    textlint-rule-common-misspellings \
    textlint-rule-no-todo \
    textlint-rule-rousseau \
    textlint-rule-unexpanded-acronym \
    textlint-rule-no-doubled-joshi \
    textlint-rule-no-mix-dearu-desumasu \
    textlint-rule-sentence-length \
    textlint-rule-spellcheck-tech-word

RUN set -x && \
  install2.r --error \
    jsonlite \
    processx \
    usethis && \
  rm -rf /tmp/downloaded_packages/ /tmp/*.rds
