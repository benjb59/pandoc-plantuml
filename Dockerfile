#
# Build stage
#
FROM eclipse-temurin:17.0.2_8-jre-centos7 as build-env

RUN apt-get update && apt-get -y install python3-pip wget
RUN pip3 install pandoc-plantuml-filter

# make plant UML

RUN mkdir -p /opt/plantuml/ 
RUN wget https://github.com/plantuml/plantuml/releases/download/v1.2022.1/plantuml-1.2022.1.jar -P /opt/plantuml/ 
RUN echo '#!/bin/bash\n\
    java -jar /opt/plantuml/plantuml-1.2022.1.jar $@' > /usr/bin/plantuml
RUN chmod a+x /usr/bin/plantuml

# Run stage
FROM eclipse-temurin:17.0.2_8-jre-centos7 as setup-env

RUN apt-get update && apt-get -y install python3 pandoc graphviz libfreetype6 fontconfig git

RUN ln -s /usr/bin/python3 /usr/bin/python

COPY --from=build-env /usr/local/lib/python3.9/dist-packages/ /usr/local/lib/python3.9/dist-packages/
COPY --from=build-env /usr/bin/plantuml /usr/bin/plantuml
COPY --from=build-env /usr/local/bin/pandoc-plantuml /usr/local/bin/pandoc-plantuml
COPY --from=build-env /opt/plantuml/ /opt/plantuml/

WORKDIR /var/docs/
ENTRYPOINT ["pandoc", "--filter", "pandoc-plantuml"]
