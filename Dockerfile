#
# Build stage
#
FROM debian:latest as build-env

# make filter
RUN apt-get update && apt-get install -y python3-pip python3-setuptools git wget
RUN pip3 install pandoc-plantuml-filter
RUN git clone https://github.com/timofurrer/pandoc-mermaid-filter.git && cd pandoc-mermaid-filter && python3 setup.py install && cd ..

# make slim-jdk
RUN wget https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz -P /tmp/
RUN tar xfvz /tmp/openjdk-17.0.2_linux-x64_bin.tar.gz -C /tmp/
RUN /tmp/jdk-17.0.2/bin/jlink --output /opt/openjdk-17-slim \
    --add-modules java.base,java.datatransfer,java.desktop,java.logging,java.prefs,java.scripting,java.xml

# make plant UML
RUN mkdir -p /opt/plantuml/ 
RUN wget https://github.com/plantuml/plantuml/releases/download/v1.2022.1/plantuml-1.2022.1.jar -P /opt/plantuml/ 
RUN echo '#!/bin/bash\n\
    /opt/openjdk-17-slim/bin/java -jar /opt/plantuml/plantuml-1.2022.1.jar $@' > /usr/bin/plantuml
RUN chmod a+x /usr/bin/plantuml

RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y -q \
  wget \
  && wget -O- https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install -y -q yarn \
  && apt-get -y -q autoremove \
  && rm -rf /var/lib/apt/lists/

RUN yarn add mermaid mermaid.cli

#
# Run stage
#
FROM debian:stretch-slim as setup-env

RUN apt-get update && apt-get install -y python3 pandoc graphviz libfreetype6 fontconfig git nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y -q \
  #texlive-latex-base \
  #texlive-fonts-recommended \
  #texlive-latex-extra \
  #texlive-xetex \
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
  nano

#RUN ln -s /usr/bin/python3 /usr/bin/python

RUN ln -s /usr/bin/nodejs /usr/bin/node

COPY --from=build-env /usr/local/lib/python3.9/dist-packages/ /usr/local/lib/python3.9/dist-packages/
COPY --from=build-env /usr/bin/plantuml /usr/bin/plantuml
COPY --from=build-env /usr/local/bin/pandoc-plantuml /usr/local/bin/pandoc-plantuml
COPY --from=build-env /opt/plantuml/ /opt/plantuml/
COPY --from=build-env /usr/local/bin/pandoc-mermaid /usr/local/bin/pandoc-mermaid
COPY --from=build-env /opt/openjdk-17-slim/ /opt/openjdk-17-slim/
COPY --from=build-env /node_modules /usr/local/lib/node_modules
RUN ln -sf /usr/local/lib/node_modules/.bin/mmdc /usr/bin/mermaid

RUN mkdir /opt/puppeteer
RUN echo "{\"args\": [\"--no-sandbox\", \"--disable-setuid-sandbox\"]}" > /opt/puppeteer/puppeteer.json

ENV PUPPETEER_CFG=/opt/puppeteer/puppeteer.json

RUN useradd -u 1000 pandoc

USER pandoc

WORKDIR /var/docs/

ENTRYPOINT ["pandoc", "--filter", "pandoc-plantuml"]
