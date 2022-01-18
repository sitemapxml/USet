fn_output_coloring_off () {
  RED=''
  GREEN=''
  YELLOW=''
  BLACK=''
  WHITE=''
  NC=''
  BGREEN=''
  BGRAY=''
  BNC=''
}

fn_output_coloring_on () {
  # Text colors
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLACK='\e[30m'
  WHITE='\e[97m'

  # Text color reset
  NC='\033[0m'

  # Background color
  BGREEN='\e[42m'
  BGRAY='\e[47m'

  # Background color reset
  BNC='\e[49m'
}

fn_insert_line () {
  printf '=%.0s' {1..70} && printf '\n'
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
    while true
      do
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
