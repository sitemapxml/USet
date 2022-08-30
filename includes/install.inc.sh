# Beginning of installation
fn_install_continue_msg () {
  echo -e ${YELLOW}"$lang_necessary_information_is_collected"${NC}
  read -p "$lang_press_enter_to_continue"
  echo -e "$lang_beginning"
  sleep 0.5s
}

# Updating repository lists
fn_update () {
  echo -e ${YELLOW}"$lang_updating_package_lists"${NC}
  sleep 0.5s
  apt-get update
}

fn_install_apache () {
  echo -e ${YELLOW}"$lang_installing_apache2_php"${NC}
  sleep 0.5s
  apt-get install apache2 -y
}

fn_install_nginx () {
  echo -e ${YELLOW}"$lang_installing_nginx_php_fpm"${NC}
  sleep 0.5s
  apt-get install nginx php-fpm -y
}

fn_enable_fpm () {
  php_version=$( php -r 'echo phpversion();' | head -c 3 )
  fpm_version="php$php_version-fpm"
  systemctl enable nginx $fpm_version
}

# Install MySQL and set root password
fn_install_mysql () {
  apt-get install mysql-server -y
  systemctl enable mysql
  mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$mysqlrpass'; FLUSH PRIVILEGES;"
}

# Installing php extensions
fn_install_php_ext () {
  echo -e ${YELLOW}"$lang_installing_php_extensions"${NC}
  sleep 0.5s
  apt-get install $conf_php_extension_list -y
}

# Install utilities
fn_install_utilities () {
  apt-get install $conf_helper_program_list -y
}

# Install imagick - Necessary for Webmin image preview to work
fn_install_imagick () {
  apt-get install imagemagick -y
}

fn_php_modify_default () {
  # Some basic php configuration
  if [ "$web_server" = "apache" ]; then
    sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/"$php_version"/apache2/php.ini
    sed -i 's/post_max_size = 8M/post_max_size = 280M/g' /etc/php/"$php_version"/apache2/php.ini
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 256M/g' /etc/php/"$php_version"/apache2/php.ini
    sed -i 's/ServerTokens OS/ServerTokens Prod/g' /etc/apache2/conf-available/security.conf
    systemctl restart apache2
  else
    sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/"$php_version"/fpm/php.ini
    sed -i 's/post_max_size = 8M/post_max_size = 280M/g' /etc/php/"$php_version"/fpm/php.ini
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 256M/g' /etc/php/"$php_version"/fpm/php.ini
    sed -i 's/# server_tokens off;/server_tokens off;/g' /etc/nginx/nginx.conf
    systemctl restart nginx $fpm_version
  fi
}

# Webmin installation
fn_install_webmin () {
  echo -e ${YELLOW}"$lang_installing_webmin"${NC}
  sleep 0.5s
  echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
  apt-key add ./resources/jcameron-key.asc
  apt-get update
  apt-get --yes install webmin
  sed -i "s/port=10000/port=$conf_webmin_port/g" /etc/webmin/miniserv.conf
  systemctl restart webmin
}

# Configure apache vhost
fn_configure_apache () {
  echo -e ${YELLOW}"$lang_configuring_apache"${NC}
  sleep 0.5s
  rm -rf '/var/www/html'
  mkdir -p "/var/www/$hostname"
  cp 'resources/apache.conf' "/etc/apache2/sites-available/$hostname.conf"
  sed -i "s/sn_default/$hostname/g" "/etc/apache2/sites-available/$hostname.conf"
  sed -i "s/dir_default/$hostname/g" "/etc/apache2/sites-available/$hostname.conf"
  a2dissite 000-default
  rm '/etc/apache2/sites-available/000-default.conf'
  a2ensite "$hostname"
  a2enmod rewrite
  systemctl restart apache2
}

fn_configure_nginx () {
  echo -e ${YELLOW}"$lang_configuring_nginx"${NC}
  sleep 0.5s
  rm -rf '/var/www/html'
  mkdir -p "/var/www/$hostname"
  cp 'resources/nginx.conf' "/etc/nginx/sites-available/$hostname.conf"
  sed -i "s/sn_default/$hostname/g" "/etc/nginx/sites-available/$hostname.conf"
  sed -i "s/dir_default/$hostname/g" "/etc/nginx/sites-available/$hostname.conf"
  ln "/etc/nginx/sites-available/$hostname.conf" "/etc/nginx/sites-enabled/$hostname.conf"
  rm '/etc/nginx/sites-available/default'
  rm '/etc/nginx/sites-enabled/default'
  systemctl restart nginx
}

# Make index.html and info.php
fn_create_index () {
  mkdir -vp "/var/www/$hostname/html"
  cp -v 'resources/index.html' "/var/www/$hostname/html/index.html"
  sed -i "s/s_title/$lang_domain $hostname $lang_is_sucessfuly_configured\!/g" "/var/www/$hostname/html/index.html"
  sed -i "s/webmin_hostname/$hostname/g" "/var/www/$hostname/html/index.html"
  echo -e "$lang_index_html_configured"
}

# Create info.php
fn_create_info () {
  echo "<?php phpinfo(); ?>" > "/var/www/$hostname/html/info.php"
  echo "$lang_info_php_configured"
}

fn_configure_system () {
  # Setting hostname according to entered domain name
  hostnamectl set-hostname "$hostname"

  # Setting up root password
  echo -e ${YELLOW}"$lang_setting_up_root_password"${NC}
  sleep 0.5s
  echo -e "root:$rootpass" | chpasswd
  echo -e ${GREEN}"$lang_password_is_updated"${NC}

  # Add UNIX user
  echo -e ${YELLOW}"$lang_adding_unix_user"${NC}
  sleep 0.5s
  adduser "$unixuser" --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
  echo -e "$unixuser:$unixpass" | chpasswd
  echo -e "$unixuser ALL=(ALL:ALL) ALL" | EDITOR='tee -a' visudo
  echo -e ${GREEN}"$lang_user_user $unixuser $lang_is_created"${NC}
}

fn_install_ssl () {
  echo -e ${YELLOW}"$lang_install_step_1"${NC}

  # Redirect to https option
  [ "$ssl_install_redirect" = 'yes' ] && local https_redirect="redirect" || local https_redirect="no-redirect"

  # Certbot installation
  echo -e "$lang_installing_ssl_certificate" && sleep 0.5s
  [ "$web_server" = "apache" ] && apt-get install python3-certbot-apache -y || apt-get install python3-certbot-nginx -y

  # Let's encrypt SSL installation
  certbot --"$web_server" --non-interactive --agree-tos --domains "$hostname" --email "$email" --"$https_redirect"

  CERTFILE="/etc/letsencrypt/live/$hostname/fullchain.pem"
  KEYFILE="/etc/letsencrypt/live/$hostname/privkey.pem"
  if [ -f "$CERTFILE" ] && [ -f "$KEYFILE" ]; then
    # Setting up SSL for Webmin
    echo -e ${YELLOW}"$lang_setting_up_ssl_for_webmin"${NC}
    sed -i '/keyfile/d' /etc/webmin/miniserv.conf
    echo -e 'keyfile=''/''etc''/''letsencrypt''/''live''/'"$hostname"'/''privkey.pem' >> /etc/webmin/miniserv.conf
    echo -e 'certfile=''/''etc''/''letsencrypt''/''live''/'"$hostname"'/''fullchain.pem' >> /etc/webmin/miniserv.conf
    systemctl restart webmin

    # Installed SSL certificate pathes
    echo -e "$lang_ssl_certificate_data" > $conf_data_folder_name/$conf_ssl_info_file_name
    certbot certificates >> $conf_data_folder_name/$conf_ssl_info_file_name
    echo -e ${GREEN}"$lang_ssl_installed"${NC}
  else
    echo -e ${RED}"$lang_ssl_install_error"${NC}
    ssl_error='1'
    sleep 0.5s
    fn_insert_line >> $conf_data_folder_name/$conf_ssl_info_file_name
    echo -е "$lang_ssl_certificate_not_installed"  >> $conf_data_folder_name/$conf_ssl_info_file_name
    echo -e "$lang_check_for_errors_and_try_again" >> $conf_data_folder_name/$conf_ssl_info_file_name
    fn_insert_line >> $conf_data_folder_name/$conf_ssl_info_file_name
  fi
}

# Protocol SSL check

fn_make_db () {
  # Check mysql server version
  mysqld_version=$( mysqld -V | awk '{print $3}' | head -c 1 )

  # Preparing database user name and password
  database_password=$( date +%s | sha256sum | base64 | head -c 32 )
  db_name=$( echo $hostname | sed 's/\./_/g' )

  if [ "$mysqld_version" -ge "8" ]; then
    mysql -u root -e "CREATE DATABASE $db_name DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci; CREATE USER '$unixuser'@'%' IDENTIFIED BY '$database_password'; GRANT ALL PRIVILEGES ON $db_name.* TO '$unixuser'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"
  else
    mysql -u root -e "CREATE DATABASE $db_name DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci; CREATE USER '$unixuser'@localhost identified by '$database_password'; GRANT ALL ON $db_name.* to '$unixuser'@localhost WITH GRANT OPTION; FLUSH PRIVILEGES;"
  fi

  fn_insert_line > $conf_db_info_file_name
  echo -e "$lang_database_access_parameters" >> $conf_db_info_file_name
  fn_insert_line >> $conf_db_info_file_name
  echo -e '\n\n'"$lang_database_name""$db_name""$lang_database_user""$unixuser""$lang_database_user_password"$database_password'\n' >> $conf_db_info_file_name
}

fn_install_adminer () {
    echo "$lang_installing_adminer"
    sleep 0.5s
    wget "https://www.adminer.org/latest${conf_adminer_build}.php"
    cp "latest${conf_adminer_build}.php" /var/www/"$hostname"/html/adminer.php
    echo ${GREEN}"$lang_adminer_installed_successfully"${NC}
    sleep 0.5s
}

fn_enable_ufw () {
    ufw allow 'OpenSSH'
    ufw allow '80/tcp'
    ufw allow '443/tcp'

    [ "$conf_webmin_install" = 'yes' ] && ufw allow "$conf_webmin_port/tcp"

    ufw --force enable && ufw reload
    echo -e ${GREEN}"$lang_port_protection_enabled"${NC}
}

fn_create_pass_backup () {
  echo -e "$lang_copying_passwords"
  sleep 0.5s
  fn_insert_line > $conf_data_folder_name/$conf_data_file_name
  echo -e "$lang_access_parameters" >> $conf_data_folder_name/$conf_data_file_name
  fn_insert_line >> $conf_data_folder_name/$conf_data_file_name

  echo -e '\n\n'"$lang_hostname""$hostname"'\n'"$lang_root_password""$rootpass"'\n\n'"$lang_unix_user""$unixuser"'\n'"$lang_unix_user_password""$unixpass"'\n' >> $conf_data_folder_name/$conf_data_file_name
  echo -e "$lang_mysql_root_password""$mysqlrpass"'\n\n'"$lang_email""$email"'\n\n' >> $conf_data_folder_name/$conf_data_file_name

  fn_insert_line >> $conf_data_folder_name/$conf_data_file_name
  echo -e "$lang_password_warning" >> $conf_data_folder_name/$conf_data_file_name
  fn_insert_line >> $conf_data_folder_name/$conf_data_file_name
  echo -e ${GREEN}"$lang_password_data_copied"${NC}
}

fn_msg_completed () {
  echo -e ${BLACK}${BGREEN}"$lang_installation_is_done"${NC}${BNC}
  echo

  if [ "$ssl_error" = "1" ]; then
    echo -e "${RED}$lang_configuring_ssl_failed${NC}"
    echo -e "$lang_check_dns_settings_and_try_again"
    echo -e "${WHITE}certbot --$web_server${NC}"
  fi

  echo -e "$lang_website_available_at_address ${GREEN}http://$hostname ${NC}"
  echo -e "$lang_chosen_webserver_is ${GREEN}$web_server${NC}"
  echo -e "$lang_you_can_check_if_php_working ${GREEN}http://$hostname/info.php${NC}"

  echo
  echo -e "$lang_webmin_installed_at_address ${GREEN}https://$hostname:$conf_webmin_port${NC}"
  echo -e "$lang_to_access_webmin_you_can_use_username ${GREEN}$unixuser${NC}"
  echo -e "$lang_and_password_created_during_installation"
  echo
  echo -e "$lang_server_webroot_is"
  echo -e "/var/www/${GREEN}$hostname${NC}/html"
  echo

if [ "$conf_create_pass_backup" = true ]; then
  echo -e "$lang_to_see_installation_data_copy_following_command"
  echo -e ${WHITE}"nano" $conf_data_folder_name"/"$conf_data_file_name${NC}
fi

if [ "$ssl_install" = true ]; then
  echo -e "$lang_following_email_will_be_used_for_receiving_ssl_warnings:\n${GREEN}$email${NC}"
else
  echo -e "$lang_your_email_address_is ${GREEN}$email${NC}"
fi
}
