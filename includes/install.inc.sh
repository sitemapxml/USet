# Beginning of installation
fn_install_continue_msg () {
  printf "${YELLOW}$lang_necessary_information_is_collected${NC}\n"
  read -p "$lang_press_enter_to_continue"
  printf "$lang_beginning\n"
  sleep 0.5s
}

# Updating repository lists
fn_update () {
  printf "${YELLOW}$lang_updating_package_lists${NC}\n"
  apt-get update
}

fn_install_apache () {
  printf "${YELLOW}$lang_installing_apache2_php${NC}\n"
  apt-get install apache2 -y
}

fn_install_php_apache () {
  if [ "$conf_install_modphp" = 'yes' ]; then
    apt-get -y install php
    php_version=$( php -r 'echo phpversion();' | head -c 3 )
    a2enmod "php$php_version"
    systemctl restart apache2
    systemctl enable apache2
  else
    systemctl stop apache2
    a2dismod mpm_prefork
    a2enmod mpm_event
    apt-get -y install php-fpm libapache2-mod-fcgid
    php_version=$( php -r 'echo phpversion();' | head -c 3 )
    a2enconf "php$php_version-fpm"
    a2enmod proxy
    a2enmod proxy_fcgi
    systemctl restart apache2
    systemctl enable apache2
  fi
}

fn_install_nginx () {
  printf "${YELLOW}$lang_installing_nginx_php_fpm${NC}\n"
  apt-get install nginx -y
  systemctl enable nginx
}

fn_install_php_nginx () {
  systemctl install php-fpm
  php_version=$( php -r 'echo phpversion();' | head -c 3 )
  systemctl enable "php$php_version-fpm"
}

# Install MySQL and set root password
fn_install_mysql () {
  apt-get install mysql-server -y
  systemctl enable mysql
  mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$conf_mysqlrpass'; FLUSH PRIVILEGES;"
}

# Installing php extensions
fn_install_php_ext () {
  printf "${YELLOW}$lang_installing_php_extensions${NC}\n"
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
  if [ "$conf_http_server" = "apache" ]; then
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
  printf "${YELLOW}$lang_installing_webmin${NC}\n"
  echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
  apt-key add ./resources/jcameron-key.asc
  apt-get update
  apt-get --yes install webmin
  sed -i "s/port=10000/port=$conf_webmin_port/g" /etc/webmin/miniserv.conf
  systemctl restart webmin
}

# Configure apache vhost
fn_configure_apache () {
  printf "${YELLOW}$lang_configuring_apache${NC}\n"
  rm -rf '/var/www/html'
  mkdir -p "/var/www/$conf_hostname"
  cp 'resources/apache.conf' "/etc/apache2/sites-available/$conf_hostname.conf"
  sed -i "s/sn_default/$conf_hostname/g" "/etc/apache2/sites-available/$conf_hostname.conf"
  sed -i "s/dir_default/$conf_hostname/g" "/etc/apache2/sites-available/$conf_hostname.conf"
  a2dissite 000-default
  rm '/etc/apache2/sites-available/000-default.conf'
  a2ensite "$conf_hostname"
  a2enmod rewrite
  systemctl restart apache2
}

fn_configure_nginx () {
  printf "${YELLOW}$lang_configuring_nginx${NC}\n"
  rm -rf '/var/www/html'
  mkdir -p "/var/www/$conf_hostname"
  cp 'resources/nginx.conf' "/etc/nginx/sites-available/$conf_hostname.conf"
  sed -i "s/sn_default/$conf_hostname/g" "/etc/nginx/sites-available/$conf_hostname.conf"
  sed -i "s/dir_default/$conf_hostname/g" "/etc/nginx/sites-available/$conf_hostname.conf"
  ln "/etc/nginx/sites-available/$conf_hostname.conf" "/etc/nginx/sites-enabled/$conf_hostname.conf"
  rm '/etc/nginx/sites-available/default'
  rm '/etc/nginx/sites-enabled/default'
  systemctl restart nginx
}

# Make index.html and info.php
fn_create_index () {
  mkdir -vp "/var/www/$conf_hostname/html"
  cp -v 'resources/index.html' "/var/www/$conf_hostname/html/index.html"
  sed -i "s/s_title/$lang_domain $conf_hostname $lang_is_sucessfuly_configured\!/g" "/var/www/$conf_hostname/html/index.html"
  sed -i "s/webmin_hostname/$conf_hostname/g" "/var/www/$conf_hostname/html/index.html"
  printf "$lang_index_html_configured\n"
}

# Create info.php
fn_create_info () {
  echo "<?php phpinfo(); ?>" > "/var/www/$conf_hostname/html/info.php"
  printf "$lang_info_php_configured\n"
}

fn_configure_system () {
  # Setting hostname according to entered domain name
  hostnamectl set-hostname "$conf_hostname"

  # Setting up root password
  printf "${YELLOW}$lang_setting_up_root_password${NC}\n"
  echo -e "root:$conf_rootpass" | chpasswd
  printf "${GREEN}$lang_password_is_updated${NC}\n"

  # Add UNIX user
  printf "${YELLOW}$lang_adding_unix_user${NC}\n"
  adduser "$conf_unixuser" --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
  echo -e "$conf_unixuser:$conf_unixpass" | chpasswd
  echo -e "$conf_unixuser ALL=(ALL:ALL) ALL" | EDITOR='tee -a' visudo
  printf "${GREEN}$lang_user_user $conf_unixuser $lang_is_created${NC}\n"
}

fn_install_ssl () {
  printf "${YELLOW}$lang_install_step_1${NC}\n"

  # Redirect to https option
  [ "$conf_ssl_redirect" = 'yes' ] && local https_redirect="redirect" || local https_redirect="no-redirect"

  # Certbot installation
  printf "$lang_installing_ssl_certificate\n"
  [ "$conf_http_server" = "apache" ] && apt-get install python3-certbot-apache -y || apt-get install python3-certbot-nginx -y

  # Let's encrypt SSL installation
  certbot --"$conf_http_server" --non-interactive --agree-tos --domains "$conf_hostname" --email "$conf_email" --"$https_redirect"

  CERTFILE="/etc/letsencrypt/live/$conf_hostname/fullchain.pem"
  KEYFILE="/etc/letsencrypt/live/$conf_hostname/privkey.pem"
  if [ -f "$CERTFILE" ] && [ -f "$KEYFILE" ]; then
    # Setting up SSL for Webmin
    printf "${YELLOW}$lang_setting_up_ssl_for_webmin${NC}\n"
    sed -i '/keyfile/d' /etc/webmin/miniserv.conf
    echo -e 'keyfile=''/''etc''/''letsencrypt''/''live''/'"$conf_hostname"'/''privkey.pem' >> /etc/webmin/miniserv.conf
    echo -e 'certfile=''/''etc''/''letsencrypt''/''live''/'"$conf_hostname"'/''fullchain.pem' >> /etc/webmin/miniserv.conf
    systemctl restart webmin

    # Installed SSL certificate pathes
    printf "$lang_ssl_certificate_data" > "$conf_data_folder_name/$conf_ssl_info_file_name"
    certbot certificates >> "$conf_data_folder_name/$conf_ssl_info_file_name"
    printf "${GREEN}$lang_ssl_installed${NC}\n"
  else
    printf "${RED}$lang_ssl_install_error${NC}\n"
    ssl_error='1'
    fn_insert_line >> "$conf_data_folder_name/$conf_ssl_info_file_name"
    printf "$lang_ssl_certificate_not_installed"  >> "$conf_data_folder_name/$conf_ssl_info_file_name"
    printf "$lang_check_for_errors_and_try_again" >> "$conf_data_folder_name/$conf_ssl_info_file_name"
    fn_insert_line >> "$conf_data_folder_name/$conf_ssl_info_file_name"
  fi
}

# Protocol SSL check

fn_make_db () {
  # Check mysql server version
  mysqld_version=$( mysqld -V | awk '{print $3}' | head -c 1 )

  # Preparing database user name and password
  database_password=$( date +%s | sha256sum | base64 | head -c 32 )
  db_name=$( echo $conf_hostname | sed 's/\./_/g' )

  if [ "$mysqld_version" -ge "8" ]; then
    mysql -u root -e "CREATE DATABASE $db_name DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci; CREATE USER '$conf_unixuser'@'%' IDENTIFIED BY '$database_password'; GRANT ALL PRIVILEGES ON $db_name.* TO '$conf_unixuser'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"
  else
    mysql -u root -e "CREATE DATABASE $db_name DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci; CREATE USER '$conf_unixuser'@localhost identified by '$database_password'; GRANT ALL ON $db_name.* to '$conf_unixuser'@localhost WITH GRANT OPTION; FLUSH PRIVILEGES;"
  fi

  fn_insert_line > "$conf_db_info_file_name"
  echo -e "$lang_database_access_parameters" >> "$conf_db_info_file_name"
  fn_insert_line >> "$conf_db_info_file_name"
  echo -e '\n\n'"$lang_database_name""$db_name""$lang_database_user""$conf_unixuser""$lang_database_user_password"$database_password'\n' >> $conf_db_info_file_name
}

fn_install_adminer () {
    printf "$lang_installing_adminer\n"
    wget "https://www.adminer.org/latest${conf_adminer_build}.php"
    cp "latest${conf_adminer_build}.php" /var/www/"$conf_hostname"/html/adminer.php
    printf "${GREEN}$lang_adminer_installed_successfully${NC}\n"
}

fn_enable_ufw () {
    ufw allow 'OpenSSH'
    ufw allow '80/tcp'
    ufw allow '443/tcp'

    [ "$conf_webmin_install" = 'yes' ] && ufw allow "$conf_webmin_port/tcp"

    ufw --force enable && ufw reload
    printf "${GREEN}$lang_port_protection_enabled${NC}\n"
}

fn_create_pass_backup () {
  printf "$lang_copying_passwords\n"
  fn_insert_line > "$conf_data_folder_name/$conf_data_file_name"
  echo -e "$lang_access_parameters" >> $conf_data_folder_name/$conf_data_file_name
  fn_insert_line >> $conf_data_folder_name/$conf_data_file_name

  echo -e '\n\n'"$lang_hostname""$conf_hostname"'\n'"$lang_root_password""$conf_rootpass"'\n\n'"$lang_unix_user""$conf_unixuser"'\n'"$lang_unix_user_password""$conf_unixpass"'\n' >> $conf_data_folder_name/$conf_data_file_name
  echo -e "$lang_mysql_root_password""$conf_mysqlrpass"'\n\n'"$lang_email""$conf_email"'\n\n' >> $conf_data_folder_name/$conf_data_file_name

  fn_insert_line >> "$conf_data_folder_name/$conf_data_file_name"
  echo -e "$lang_password_warning" >> "$conf_data_folder_name/$conf_data_file_name"
  fn_insert_line >> "$conf_data_folder_name/$conf_data_file_name"
  printf "${GREEN}$lang_password_data_copied${NC}\n"
}

fn_msg_completed () {
  printf "${BLACK}${BGREEN}$lang_installation_is_done${NC}${BNC}\n"
  echo

  if [ "$ssl_error" = "1" ]; then
    printf "${RED}$lang_configuring_ssl_failed${NC}\n"
    printf "$lang_check_dns_settings_and_try_again\n"
    printf "${WHITE}certbot --$conf_http_server${NC}\n"
  fi

  printf "$lang_website_available_at_address ${GREEN}http://${hostname}${NC}\n"
  printf "$lang_chosen_webserver_is ${GREEN}$conf_http_server${NC}\n"
  printf "$lang_you_can_check_if_php_working ${GREEN}http://$conf_hostname/info.php${NC}\n"

  echo
  printf "$lang_webmin_installed_at_address ${GREEN}https://$conf_hostname:$conf_webmin_port${NC}\n"
  printf "$lang_to_access_webmin_you_can_use_username ${GREEN}$conf_unixuser${NC}\n"
  printf "$lang_and_password_created_during_installation\n"
  echo
  printf "$lang_server_webroot_is\n"
  printf "/var/www/${GREEN}$conf_hostname${NC}/html\n"
  echo

if [ "$conf_create_pass_backup" = true ]; then
  printf "$lang_to_see_installation_data_copy_following_command\n"
  printf "${WHITE}nano ${conf_data_folder_name}/${conf_data_file_name}${NC}\n"
fi

if [ "$conf_ssl_install" = true ]; then
  printf "$lang_following_email_will_be_used_for_receiving_ssl_warnings:\n${GREEN}$conf_email${NC}\n"
else
  printf "$lang_your_email_address_is ${GREEN}$conf_email${NC}\n"
fi
}
