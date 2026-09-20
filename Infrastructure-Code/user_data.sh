#!/bin/bash
yum install -y httpd php php-mysqlnd amazon-efs-utils
# httpd installs the apache web server that wordpress is hosted on
# php installs the php runtime for wordpress since wordpress is a php application
# php-mysqlnd allows php to communicate with the mysql rds database
# amazon-efs-utils helps simplify mounting amazon efs systems
mkdir -p /var/www/html/wp-content/uploads
# creates the directory for the hosting and storage of the images that wordpress uses -p creates any missing directories
mount -t efs -o tls ${efs_id}:/ /var/www/html/wp-content/uploads
# -t efs uses the amazon-efs-utils to use the mount type
# -o tls enables encryption in transit
# {efs_id} references the efs id instead of hardcoding it for best practice :/ connects the root directory to efs
# /var/www/html/wp-content/uploads the directory efs mounts to on the ec2 instance
db_password=$(aws secretsmanager get-secret-value --secret-id db_password --query SecretString --output text --region us-east-1)
# holds the database password retrieval script in a variable that will be referenced and used when the asg boots up and uses the user data commands.
wget -P /tmp https://wordpress.org/latest.tar.gz
tar -xzf /tmp/latest.tar.gz -C /var/www/html --strip-components=1
# wget -P specifies the destination directory (/tmp for temporary files), and downloads the entire wordpress file into a zip
# tar -xzf tells the script to extract (x) decompress the file (z) and specify the actual file being extracted and decompressed (f), 
# uses -C to change directories to the /var/www/html directory and uses --strip-components=1 to strip away the parent directory
cat > /var/www/html/wp-config.php << EOF
<?php
define('DB_NAME', '${db_name}');
define('DB_USER', '${username}');
define('DB_PASSWORD', '${db_password}');
define('DB_HOST', '${db_host}');
EOF
# tells wordpress how to connect to the database, references necesarry information that is injected on boot from the launch configuration
cat >> /var/www/html/wp-config.php << EOF
\$table_prefix = 'wp_';
require_once ABSPATH . 'wp-settings.php';
EOF
# loads the wordpress instance and establishes which database prefix to use in this case "wp_"

chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html
# Fix ownership and permissions so Apache can read/write WordPress files

systemctl start httpd
systemctl enable httpd
# starts and enables apache
