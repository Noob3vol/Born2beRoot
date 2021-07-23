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
