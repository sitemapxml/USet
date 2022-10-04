conf_skip_confirm=$(get_value "skip-confirm" "$@")

conf_language=$(get_value "language" "$@")
conf_disable_colors=$(get_value "colors" "$@")
conf_skip_welcome=$(get_value "welcome" "$@")

conf_debug=$(get_value "debug" "$@")
conf_ignore_lockfile=$(get_value "lock-ignore" "$@")
conf_create_lockfile=$(get_value "lock-create" "$@")

conf_data_folder_name=$(get_value "data-dirname" "$@")
conf_data_file_name=$(get_value "data-filename" "$@")
conf_ssl_info_file_name=$(get_value "sslinfo-filename" "$@")
conf_db_info_file_name=$(get_value "dbinfo-filename" "$@")

conf_php_extension_list=$(get_value "php-extensions" "$@")
conf_helper_program_list=$(get_value "packages" "$@")

conf_install_mysql=$(get_value "install-mysql" "$@")

conf_webmin_install=$(get_value "install-webmin" "$@")
conf_webmin_port=$(get_value "webmin-port" "$@")
conf_webmin_ssl_mode=$(get_value "webmin-ssl" "$@")
conf_install_imagemagick=$(get_value "install-imagick" "$@")

conf_create_index=$(get_value "create-index" "$@")
conf_create_phpinfo=$(get_value "create-phpinfo" "$@")
conf_install_adminer=$(get_value "install-adminer" "$@")
conf_adminer_build=$(get_value "adminer-build" "$@")
conf_enable_ufw=$(get_value "ufw-enable" "$@")
conf_create_pass_backup=$(get_value "pass-backup" "$@")

conf_hostname=$(get_value "hostname" "$@")
conf_rootpass=$(get_value "rootpass" "$@")
conf_unixuser=$(get_value "unixuser" "$@")
conf_unixpass=$(get_value "unixpass" "$@")
conf_mysqlrpass=$(get_value "mysqlrpass" "$@")
conf_email=$(get_value "email" "$@")
conf_http_server=$(get_value "web-server" "$@")

conf_install_modphp=$(get_value "install-modphp" "$@")
conf_disable_preinstall=$(get_value "preinstall-disable" "$@")
conf_disable_postinstall=$(get_value "postinstall-disable" "$@")

conf_ssl_install=$(get_value "ssl-install" "$@")
conf_ssl_redirect=$(get_value "ssl-redirect" "$@")
