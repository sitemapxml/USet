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
