skip_interaction=$(get_value "skip-interaction" "$@")

conf_language=$(get_value "language" "$@")
conf_disable_colors=$(get_value "disable-colors" "$@")
conf_skip_welcome_screen=$(get_value "skip-welcome" "$@")

conf_data_folder_name=$(get_value "data-folder-name" "$@")
conf_data_file_name=$(get_value "data-file-name" "$@")
conf_ssl_info_file_name=$(get_value "sslinfo-file-name" "$@")
conf_db_info_file_name=$(get_value "dbinfo-file-name" "$@")

conf_php_extension_list=$(get_value "install-php-extensions" "$@")
conf_helper_program_list=$(get_value "install-programs" "$@")

conf_webmin_install=$(get_value "install-webmin" "$@")
conf_webmin_port=$(get_value "webmin-port" "$@")
conf_webmin_ssl_mode=$(get_value "webmin-ssl" "$@")
conf_install_imagemagick=$(get_value "install-imagemagick" "$@")

conf_create_index_html=$(get_value "create-index-html" "$@")
conf_create_info_php=$(get_value "create-phpinfo" "$@")
conf_install_adminer=$(get_value "install-adminer" "$@")
conf_adminer_build=$(get_value "adminer-build" "$@")
conf_enable_ufw=$(get_value "ufw-enable" "$@")
conf_create_pass_backup=$(get_value "password-backup" "$@")

hostname=$(get_value "hostname" "$@")
rootpass=$(get_value "rootpass" "$@")
unixuser=$(get_value "unixuser" "$@")
unixpass=$(get_value "unixpass" "$@")
mysqlrpass=$(get_value "mysqlrpass" "$@")
email=$(get_value "email" "$@")
web_server=$(get_value "server-type" "$@")

ssl_install=$(get_value "ssl-install" "$@")
ssl_install_redirect=$(get_value "ssl-install-redirect" "$@")
