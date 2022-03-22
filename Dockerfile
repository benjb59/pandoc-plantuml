#
# Build stage
#
FROM openjdk:17-slim-bullseye as build-env-java
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update && apt-get install -y git python3-pip
RUN pip3 install pandoc-plantuml-filter
RUN git clone https://github.com/timofurrer/pandoc-mermaid-filter.git && cd pandoc-mermaid-filter && python3 setup.py install && cd ..

# make plant UML
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update && apt-get install -y wget
RUN mkdir -p /opt/plantuml/ 
RUN wget https://github.com/plantuml/plantuml/releases/download/v1.2022.1/plantuml-1.2022.1.jar -P /opt/plantuml/ 
RUN echo '#!/bin/bash\n\
    /usr/local/openjdk-17/bin/java -jar /opt/plantuml/plantuml-1.2022.1.jar $@' > /usr/bin/plantuml
RUN chmod a+x /usr/bin/plantuml

# make mermaid
FROM node:17-bullseye-slim as build-env-node
RUN yarn add mermaid mermaid.cli

#
# Run stage
#
FROM debian:bullseye-slim as setup-env

RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y -q \
  nodejs \
  pandoc \
  graphviz \
  libfreetype6 \
  fontconfig \
  git \
  nano \
  # puppeteer dependencies
  libx11-xcb-dev \
  libxcomposite-dev \
  libxcursor-dev \
  libxdamage-dev \
  libxtst-dev \
  libxss-dev \
  libxrandr-dev \
  libasound-dev \
  libatk1.0-dev \
  libatk-bridge2.0-dev \
  libpango1.0-dev \
  libgtk-3-dev \
  libnss3 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3 /usr/bin/python

COPY --from=build-env-java /usr/bin/plantuml /usr/bin/plantuml
COPY --from=build-env-java /opt/plantuml /opt/plantuml
COPY --from=build-env-java /usr/local/openjdk-17 /usr/local/openjdk-17

COPY --from=build-env-java /usr/local/lib/python3.9/dist-packages /usr/local/lib/python3.9/dist-packages
COPY --from=build-env-java /usr/local/bin/pandoc-plantuml /usr/local/bin/pandoc-plantuml
COPY --from=build-env-java /usr/local/bin/pandoc-mermaid /usr/local/bin/pandoc-mermaid

COPY --from=build-env-node /node_modules /usr/local/lib/node_modules

RUN ln -sf /usr/local/lib/node_modules/.bin/mmdc /usr/bin/mermaid

# puppeteer conf
RUN mkdir /opt/puppeteer
RUN echo "{\"args\": [\"--no-sandbox\", \"--disable-setuid-sandbox\"]}" > /opt/puppeteer/puppeteer.json
ENV PUPPETEER_CFG=/opt/puppeteer/puppeteer.json

RUN useradd pandoc

RUN mkdir /var/docs && chown pandoc /var/docs

USER pandoc

WORKDIR /var/docs/

ENTRYPOINT ["pandoc", "--filter", "pandoc-plantuml", "--filter", "pandoc-mermaid"]