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

# Удаляем Java 9+ параметры из всех скриптов
RUN find ${DRILL_HOME}/bin -name "*.sh" -exec sed -i 's/--add-opens[^[:space:]]*//' {} \; && \
    find ${DRILL_HOME}/bin -name "*.sh" -exec sed -i 's/--add-exports[^[:space:]]*//' {} \; && \
    find ${DRILL_HOME}/bin -name "*.sh" -exec sed -i 's/-Xms[0-9][0-9]*[mMgG]/-Xms32m/g' {} \; && \
    find ${DRILL_HOME}/bin -name "*.sh" -exec sed -i 's/-Xmx[0-9][0-9]*[mMgG]/-Xmx192m/g' {} \; && \
    find ${DRILL_HOME}/bin -name "*.sh" -exec sed -i 's/-XX:MaxDirectMemorySize=[0-9][0-9]*[mMgG]/-XX:MaxDirectMemorySize=64m/g' {} \;

# Создаем минимальный drill-env.sh
RUN echo '#!/bin/bash' > ${DRILL_HOME}/conf/drill-env.sh && \
    echo 'export DRILL_JAVA_OPTS="$DRILL_JAVA_OPTS -Xms32m -Xmx192m -XX:MaxDirectMemorySize=64m -XX:+UseSerialGC -XX:MaxMetaspaceSize=64m -Ddrill.exec.options.planner.parser.enable_unicode_literals=false"' >> ${DRILL_HOME}/conf/drill-env.sh && \
    chmod +x ${DRILL_HOME}/conf/drill-env.sh

# Удаляем ненужные модули
RUN rm -rf ${DRILL_HOME}/jars/drill-storage-hbase* \
           ${DRILL_HOME}/jars/drill-storage-hive* \
           ${DRILL_HOME}/jars/drill-storage-kafka* \
           ${DRILL_HOME}/jars/drill-storage-mongo* \
           ${DRILL_HOME}/jars/drill-storage-elasticsearch* \
           ${DRILL_HOME}/jars/drill-storage-cassandra* \
           ${DRILL_HOME}/jars/drill-kudu* \
           ${DRILL_HOME}/jars/drill-druid* \
           ${DRILL_HOME}/jars/drill-format-hdf5* \
           ${DRILL_HOME}/jars/drill-format-excel* \
           ${DRILL_HOME}/jars/drill-format-pdf* \
           ${DRILL_HOME}/jars/drill-iceberg*

# Конфигурация
COPY drill-override.conf ${DRILL_HOME}/conf/

ENV PATH=$PATH:${DRILL_HOME}/bin

RUN adduser -D drill && chown -R drill:drill ${DRILL_HOME}
USER drill

EXPOSE 8047
WORKDIR ${DRILL_HOME}

CMD ["bin/drill-embedded"]
