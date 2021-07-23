DATABASE_NAME=wpdb
DATABASE_USER=wpuser
DATABASE_PASS=born2beroot

DATABASE_ROOT_PASS=NewRootPass


cd /tmp
#rm -f latest.tar.*
#wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
rm -rf /var/www/html/*
sed -i "s/database_name_here/${DATABASE_NAME}/" /tmp/wordpress/wp-config-sample.php
sed -i "s/username_here/${DATABASE_USER}/" /tmp/wordpress/wp-config-sample.php
sed -i "s/password_here/${DATABASE_PASS}/" /tmp/wordpress/wp-config-sample.php
mv /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
cp -R wordpress/* /var/www/html
chmod -R 755 /var/www/html
chown lighttpd:lighttpd /var/www/html

# Clean MariaDB install
systemctl start mariadb

mysql -u root << EOF
UPDATE mysql.user SET Password=('${DATABASE_ROOT_PASS}') WHERE User='root';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
CREATE DATABASE ${DATABASE_NAME};
GRANT ALL PRIVILEGES on ${DATABASE_NAME}.* TO '${DATABASE_USER}'@'localhost' IDENTIFIED by '${DATABASE_PASS}';
FLUSH PRIVILEGES;
EOF
