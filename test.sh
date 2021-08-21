DATABASE_NAME=wpdb
DATABASE_USER=wpuser
DATABASE_PASS=born2beroot

DATABASE_ROOT_PASS=NewRootPass

dnf install lighttpd lighttpd-fastcgi -y
dnf install php php-fpm php-gd php-mysqlnd -y
dnf install php-zip php-curl php-mbstring php-bcmath php-soap -y
dnf install mariadb mariadb-server -y



# Configure php
sed -i "s/user = apache/user = lighttpd" /etc/php-fpm.d/www.conf
sed -i "s/group = apache/group = lighttpd" /etc/php-fpm.d/www.conf
user
sed -i "s/#\(include \"conf.d/fastcgi.conf\"\)/\1/" /etc/lighttpd/module.conf


# Configure wordpress
cd /tmp
#rm -f latest.tar.*
#wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
rm -rf /var/www/html/*
sed -i "s/database_name_here/${DATABASE_NAME}/" /tmp/wordpress/wp-config-sample.php
sed -i "s/username_here/${DATABASE_USER}/" /tmp/wordpress/wp-config-sample.php
sed -i "s/password_here/${DATABASE_PASS}/" /tmp/wordpress/wp-config-sample.php
mv /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
cp -R wordpress/* /var/www/lighttpd
chmod -R 755 /var/www/lighttpd
chown lighttpd:lighttpd /var/www/lighttpd

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
