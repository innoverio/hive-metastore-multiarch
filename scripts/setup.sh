#!/bin/bash -ex

mysql_install_db

chown -R mysql:mysql /var/lib/mysql

mysqld_safe &
while ! nc -z localhost 3306; do
  sleep 1
done

echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" | mysql
echo "CREATE DATABASE metastore;" | mysql
/usr/bin/mysqladmin -u root password 'root'

/opt/apache-hive-metastore-3.0.0-bin/bin/schematool -initSchema -dbType mysql

pkill mysqld

sleep 10s
rm -rf /tmp/* /var/tmp/*

rm -rf ${HIVE_HOME}/conf/metastore-site.xml