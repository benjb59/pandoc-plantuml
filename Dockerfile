#
# Build stage
#
FROM debian:latest as build-env

RUN apt-get update && apt-get install -y python3-pip wget
RUN pip3 install pandoc-plantuml-filter

# make slim-jdk
RUN wget https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz -P /tmp/
RUN tar xfvz /tmp/openjdk-17.0.2_linux-x64_bin.tar.gz -C /tmp/
RUN /tmp/jdk-17.0.2/bin/jlink --output /opt/openjdk-17-slim \
    --add-modules java.base,java.datatransfer,java.desktop,java.logging,java.prefs,java.scripting,java.xml

# make plant UML

RUN mkdir -p /opt/plantuml/ 
RUN wget https://github.com/plantuml/plantuml/releases/download/v1.2022.1/plantuml-1.2022.1.jar -P /opt/plantuml/ 
RUN echo '#!/bin/bash\n\
    java -jar /opt/plantuml/plantuml-1.2022.1.jar $@' > /usr/bin/plantuml
RUN chmod a+x /usr/bin/plantuml

#
# Run stage
#
FROM debian:latest as setup-env

RUN apt-get update && apt-get install -y python3 pandoc graphviz libfreetype6 fontconfig git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3 /usr/bin/python

COPY --from=build-env /usr/local/lib/python3.9/dist-packages/ /usr/local/lib/python3.9/dist-packages/
COPY --from=build-env /usr/bin/plantuml /usr/bin/plantuml
COPY --from=build-env /usr/local/bin/pandoc-plantuml /usr/local/bin/pandoc-plantuml
COPY --from=build-env /opt/plantuml/ /opt/plantuml/

WORKDIR /var/docs/
ENTRYPOINT ["pandoc", "--filter", "pandoc-plantuml"]
