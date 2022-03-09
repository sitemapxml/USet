fn_install () {
  # Beginning of installation
  echo
  echo -e ${YELLOW}"$lang_necessary_information_is_collected"${NC}
  read -p "$lang_press_enter_to_continue"
  echo -e "$lang_beginning"
  sleep 1s

  # Updating repository lists
  echo -e ${YELLOW}"$lang_updating_package_lists"${NC}
  sleep 1s
  apt-get update

  # Adding main repository if not added
  echo -e ${YELLOW}"$lang_adding_repositories"${NC}
  add-apt-repository main

  # Adding universe repository - disabled by default
  if [ "$conf_add_apt_repository_universe" = "true" ]; then
      add-apt-repository universe
  fi

  apt-get update

  # Install software-properties-common if not installed
  # make sure that apt-transport-https is installed
  apt-get install software-properties-common apt-transport-https -y

  if [ "$web_server" = "apache" ]; then
    echo -e ${YELLOW}"$lang_installing_apache2_php"${NC}
    sleep 1s
    apt-get install apache2 php -y
    systemctl enable apache2
  else
    echo -e ${YELLOW}"$lang_installing_nginx_php_fpm"${NC}
    sleep 1s
    apt-get install nginx php-fpm -y

    # Check for php version
    php_version=$( php -r 'echo phpversion();' | head -c 3 )
    fpm_version="php$php_version-fpm"

    systemctl enable nginx $fpm_version
  fi

  # MySQL installation
  apt-get install mysql-server -y
  systemctl enable mysql

  # Installing php extensions
  echo -e ${YELLOW}"$lang_installing_php_extensions"${NC}
  sleep 1s
  apt-get install $conf_php_extension_list -y

  # Small helper programs zip, unzip i tree
  apt-get install $conf_helper_program_list -y

  # Installing imagick - Necessary for Webmin image preview to work
  if [ "$conf_install_imagemagick" = "true" ]; then
    apt-get install imagemagick -y
  else
    echo -e "$lang_skipping_imagemagick"
  fi

  # Check for php version
  php_version=$( php -r 'echo phpversion();' | head -c 3 )

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

  # Setting hostname according to entered domain name
  hostnamectl set-hostname "$hostname"

  if [ "$conf_webmin_install" = "false" ]; then
    echo -e "$lang_skipping_webmin"
  else
    # Webmin installation
    echo -e ${YELLOW}"$lang_installing_webmin"${NC}
    sleep 1s
    echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
    apt-key add ./resources/jcameron-key.asc
    apt-get update
    apt-get --yes install webmin
    sed -i "s/port=10000/port=$conf_webmin_port/g" /etc/webmin/miniserv.conf
    /etc/init.d/webmin restart
  fi

  rm -rf /var/www/html
  mkdir /var/www/"$hostname"

  # Configuring apache
  if [ "$web_server" = "apache" ]; then
    echo -e ${YELLOW}"$lang_configuring_apache"${NC}
    sleep 1s
    cp ./resources/apache.conf /etc/apache2/sites-available/"$hostname".conf
    sed -i "s/sn_default/$hostname/g" /etc/apache2/sites-available/"$hostname".conf
    sed -i "s/dir_default/$hostname/g" /etc/apache2/sites-available/"$hostname".conf
    a2dissite 000-default
    rm /etc/apache2/sites-available/000-default.conf
    a2ensite "$hostname"
    a2enmod rewrite
    systemctl restart apache2
  else
    echo -e ${YELLOW}"$lang_configuring_nginx"${NC}
    sleep 1s
    cp ./resources/nginx.conf /etc/nginx/sites-available/"$hostname".conf
    sed -i "s/sn_default/$hostname/g" /etc/nginx/sites-available/"$hostname".conf
    sed -i "s/dir_default/$hostname/g" /etc/nginx/sites-available/"$hostname".conf
    ln /etc/nginx/sites-available/"$hostname".conf /etc/nginx/sites-enabled/"$hostname".conf
    rm /etc/nginx/sites-available/default
    rm /etc/nginx/sites-enabled/default
    systemctl restart nginx
  fi

  # Add UNIX user
  echo -e ${YELLOW}"$lang_adding_unix_user"${NC}
  sleep 1s
  adduser "$unixuser" --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
  echo -e "$unixuser:$unixpass" | chpasswd
  echo -e "$unixuser ALL=(ALL:ALL) ALL" | EDITOR='tee -a' visudo
  echo -e ${GREEN}"$lang_user_user $unixuser $lang_is_created"${NC}

  # Setting up root password
  echo -e ${YELLOW}"$lang_setting_up_root_password"${NC}
  sleep 1s
  echo -e "root:$rootpass" | chpasswd
  echo -e ${GREEN}"$lang_password_is_updated"${NC}

  # Setting up password for mysql root
  mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$mysqlrpass';"

  # Creating directory for saving output files
  mkdir $conf_data_folder_name
}

fn_install_ssl () {
  echo -e ${YELLOW}"$lang_install_step_1"${NC}

  # Redirect to https option
  if  [ -n "$ssl_install_redirect" ]; then
    if  [ "$ssl_install_redirect" = 'true' ]; then
      https_redirect="redirect"
    else
      https_redirect="no-redirect"
    fi
  else
    while true; do
      read -p "$lang_do_you_want_to_enable_redirect_to_https $lang_yes_no" ssl_redirect
        case $ssl_redirect in
        [Yy][Ee][Ss]|[Yy])
          https_redirect="redirect"
        break
        ;;
        [Nn][Oo]|[Nn])
          https_redirect="no-redirect"
      break
        ;;
      *)
        echo -e ${RED}"$lang_answer_yes_no"${NC}
      ;;
      esac
    done
  fi

  echo -e "$lang_installing_ssl_certificate"
  sleep 1s
  # Certbot installation
  if [ "$web_server" = "apache" ]; then
    apt-get install python3-certbot-apache -y
  else
    apt-get install python3-certbot-nginx -y
  fi

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
    /etc/init.d/webmin restart

    # Installed SSL certificate pathes
    echo -e "$lang_ssl_certificate_data" > $conf_data_folder_name/$conf_ssl_info_file_name
    certbot certificates >> $conf_data_folder_name/$conf_ssl_info_file_name
    echo -e ${GREEN}"$lang_ssl_installed"${NC}
  else
    echo -e ${RED}"$lang_ssl_install_error"${NC}
    ssl_error='1'
    sleep 1s
    fn_insert_line >> $conf_data_folder_name/$conf_ssl_info_file_name
    echo -е "$lang_ssl_certificate_not_installed"  >> $conf_data_folder_name/$conf_ssl_info_file_name
    echo -e "$lang_check_for_errors_and_try_again" >> $conf_data_folder_name/$conf_ssl_info_file_name
    fn_insert_line >> $conf_data_folder_name/$conf_ssl_info_file_name
  fi
}

fn_make_index () {
  mkdir /var/www/"$hostname"/html

  if [ "$conf_create_index_html" = "true" ]; then
    cp ./resources/index.html /var/www/"$hostname"/html/index.html
  	sed -i "s/s_title/$lang_domain $hostname $lang_is_sucessfuly_configured\!/g" /var/www/"$hostname"/html/index.html
    sed -i "s/webmin_hostname/$hostname/g" /var/www/"$hostname"/html/index.html

    echo -e "$lang_index_html_configured"
  else
    echo "$lang_skipping_creation_of_index_html"
  fi

  # Create info.php
  if [ "$conf_create_info_php" = 'true' ]; then
    echo "<?php phpinfo(); ?>" > /var/www/"$hostname"/html/info.php
    echo "$lang_info_php_configured"
  else
    echo "$lang_skipping_creation_of_info_php"
  fi
}

fn_make_db () {
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
