show_info () {
  echo "--skip-interaction skip_interaction: $skip_interaction"
  echo "--language conf_language: $conf_language"
  echo "--disable-colors conf_disable_colors: $conf_disable_colors"
  echo "--skip-welcome conf_skip_welcome: $conf_skip_welcome"
  echo "--data-folder-name conf_data_folder_name: $conf_data_folder_name"
  echo "--data-file-name conf_data_file_name: $conf_data_file_name"
  echo "--sslinfo-file-name conf_ssl_info_file_name: $conf_ssl_info_file_name"
  echo "--dbinfo-file-name conf_db_info_file_name: $conf_db_info_file_name"
  echo "--install-php-extensions conf_php_extension_list: $conf_php_extension_list"
  echo "--install-programs conf_helper_program_list: $conf_helper_program_list"
  echo "--install-mysql conf_install_mysql: $conf_install_mysql"
  echo "--install-webmin conf_webmin_install: $conf_webmin_install"
  echo "--webmin-port conf_webmin_port: $conf_webmin_port"
  echo "--webmin-ssl conf_webmin_ssl_mode: $conf_webmin_ssl_mode"
  echo "--install-imagick conf_install_imagemagick: $conf_install_imagemagick"
  echo "--create-index conf_create_index: $conf_create_index"
  echo "--create-phpinfo conf_create_phpinfo: $conf_create_phpinfo"
  echo "--install-adminer conf_install_adminer: $conf_install_adminer"
  echo "--adminer-build conf_adminer_build: $conf_adminer_build"
  echo "--ufw-enable conf_enable_ufw: $conf_enable_ufw"
  echo "--password-backup conf_create_pass_backup: $conf_create_pass_backup"
  echo "--hostname hostname: $hostname"
  echo "--rootpass rootpass: $rootpass"
  echo "--unixuser unixuser: $unixuser"
  echo "--unixpass unixpass: $unixpass"
  echo "--mysqlrpass mysqlrpass: $mysqlrpass"
  echo "--email email: $email"
  echo "--server-type web_server: $web_server"
  echo "--install-modphp conf_install_modphp: $conf_install_modphp"
  echo "--disable-preinstall conf_disable_preinstall: $conf_disable_preinstall"
  echo "--disable-postinstall conf_disable_postinstall: $conf_disable_postinstall"
  echo "--ssl-install ssl_install: $ssl_install"
  echo "--ssl-redirect ssl_install_redirect: $ssl_install_redirect"
}
