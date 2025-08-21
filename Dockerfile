FROM openjdk:8-jdk-alpine

LABEL description="Apache Drill 1.20.3 minimal for 1GB RAM"

# Установим только необходимое
RUN apk add --no-cache wget curl bash

# Установим Drill
ENV DRILL_HOME=/opt/drill
RUN wget https://archive.apache.org/dist/drill/1.20.3/apache-drill-1.20.3.tar.gz && \
    tar -xzf apache-drill-1.20.3.tar.gz && \
    mv apache-drill-1.20.3 ${DRILL_HOME} && \
    rm apache-drill-1.20.3.tar.gz

# MySQL драйвер
RUN wget -O ${DRILL_HOME}/jars/3rdparty/mysql-connector-java-8.0.30.jar \
    https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.30/mysql-connector-java-8.0.30.jar

# Создаем простой launch скрипт вместо использования оригинальных
RUN echo '#!/bin/bash' > ${DRILL_HOME}/bin/drill-simple && \
    echo 'export JAVA_HOME=/usr/local/openjdk-8' >> ${DRILL_HOME}/bin/drill-simple && \
    echo 'export DRILL_JAVA_OPTS="-Xms32m -Xmx192m -XX:MaxDirectMemorySize=64m -XX:+UseSerialGC -XX:MaxMetaspaceSize=64m -Ddrill.exec.options.planner.parser.enable_unicode_literals=false -Dfile.encoding=UTF-8"' >> ${DRILL_HOME}/bin/drill-simple && \
    echo 'cd /opt/drill' >> ${DRILL_HOME}/bin/drill-simple && \
    echo 'exec $JAVA_HOME/bin/java $DRILL_JAVA_OPTS -cp "conf:jars/*:jars/ext/*:jars/3rdparty/*" sqlline.SqlLine -ac org.apache.drill.exec.client.DrillSqlLineApplication --color=true -u "jdbc:drill:zk=local"' >> ${DRILL_HOME}/bin/drill-simple && \
    chmod +x ${DRILL_HOME}/bin/drill-simple

# Конфигурация
COPY drill-override.conf ${DRILL_HOME}/conf/

ENV PATH=$PATH:${DRILL_HOME}/bin

RUN adduser -D drill && chown -R drill:drill ${DRILL_HOME}
USER drill

EXPOSE 8047
WORKDIR ${DRILL_HOME}

# Используем наш простой скрипт
CMD ["bin/drill-simple"]
