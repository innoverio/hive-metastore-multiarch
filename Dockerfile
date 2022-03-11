FROM amazoncorretto:8

WORKDIR /opt

ENV HADOOP_VERSION=3.2.0
ENV METASTORE_VERSION=3.0.0
ENV HADOOP_HOME=/opt/hadoop-3.2.0
ENV HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-3.2.0.jar
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto
ENV METASTORE_DB_HOSTNAME=localhost

ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HIVE_HOME=/opt/apache-hive-metastore-${METASTORE_VERSION}-bin

RUN amazon-linux-extras install epel && yum install -y tar nc gzip shadow-utils mariadb-server procps-ng python3 python3-pip && \
    yum -q clean all && rm -rf /var/cache/yum

RUN curl -L https://downloads.apache.org/hive/hive-standalone-metastore-${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz | tar zxf - && \
    curl -L https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf - && \
    curl -L https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.19.tar.gz | tar zxf - && \
    cp mysql-connector-java-8.0.19/mysql-connector-java-8.0.19.jar ${HIVE_HOME}/lib/ && \
    rm -rf  mysql-connector-java-8.0.19 && \
    pip3 install supervisor

COPY scripts/setup.sh /setup.sh

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME} && \
    chmod +x /setup.sh

COPY conf/metastore-site.xml ${HIVE_HOME}/conf/metastore-site.xml

COPY conf/supervisord.d /etc/supervisord.d/
COPY conf/supervisord.conf /etc/

RUN /setup.sh

RUN mkdir /var/log/hive && \
    chown hive:hive /var/log/hive && \
    mkdir /var/log/mysql && \
    chown mysql:mysql /var/log/mysql


EXPOSE 9083

CMD supervisord -c /etc/supervisord.conf