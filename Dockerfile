FROM openjdk:8-jre-slim

LABEL maintainer="your-email@example.com"
LABEL description="Apache Drill 1.20.4 with Unicode literals fix"

# Установим необходимые пакеты
RUN apt-get update && \
    apt-get install -y wget curl && \
    rm -rf /var/lib/apt/lists/*

# Установим Drill 1.20.4
ENV DRILL_VERSION=1.20.3
ENV DRILL_HOME=/opt/drill

RUN wget https://archive.apache.org/dist/drill/drill-${DRILL_VERSION}/apache-drill-${DRILL_VERSION}.tar.gz && \
    tar -xzf apache-drill-${DRILL_VERSION}.tar.gz && \
    mv apache-drill-${DRILL_VERSION} ${DRILL_HOME} && \
    rm apache-drill-${DRILL_VERSION}.tar.gz

# Скачаем MySQL драйвер
RUN wget -O ${DRILL_HOME}/jars/3rdparty/mysql-connector-java-8.0.33.jar \
    https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.33/mysql-connector-java-8.0.33.jar

# Копируем конфигурацию
COPY drill-override.conf ${DRILL_HOME}/conf/

# Настройки окружения
ENV PATH=$PATH:${DRILL_HOME}/bin
ENV DRILL_JAVA_OPTS="-Ddrill.exec.options.planner.parser.enable_unicode_literals=false -Dfile.encoding=UTF-8 -Xms1G -Xmx4G"

# Создаем пользователя для Drill
RUN groupadd -r drill && useradd -r -g drill drill && \
    chown -R drill:drill ${DRILL_HOME}

USER drill

EXPOSE 8047 31010

WORKDIR ${DRILL_HOME}

# Здоровье контейнера
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8047/ || exit 1

CMD ["bin/drillbit.sh", "run"]
