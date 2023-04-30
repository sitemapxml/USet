#!/bin/bash

fn_wizard () {

conf_webmin_install=''

  whiptail --title "USet" --scrolltext --msgbox "$lang_welcome" 20 65
  
  conf_hostname=$(whiptail --title "Domain name" --inputbox "Please enter domain name without protocol (without http://):" 10 80 3>&1 1>&2 2>&3)
  while true; do
    conf_rootpass=$(whiptail --title "Server root password" --passwordbox "Enter root user password for your server" 10 80 3>&1 1>&2 2>&3)
    conf_rootpass2=$(whiptail --title "Server root password" --passwordbox "Enter password again to confirm:" 10 80 3>&1 1>&2 2>&3)
    [ "$conf_rootpass" = "$conf_rootpass2" ] && break
  done

  conf_unixuser=$(whiptail --title "System User Details" --inputbox "Enter UNIX user username:" 10 80 3>&1 1>&2 2>&3)
  while true; do
    conf_unixpass=$(whiptail --title "System User Details" --passwordbox "Enter UNIX user password:" 10 80 3>&1 1>&2 2>&3)
    conf_unixpass2=$(whiptail --title "System User Details" --passwordbox "Enter password again to confirm:" 10 80 3>&1 1>&2 2>&3)
    [ "$conf_unixpass" = "$conf_unixpass2" ] && break
  done

  while true; do
    conf_mysqlrpass=$(whiptail --title "Password for MYSQL root" --passwordbox "Enter password for mysql root:" 10 80 3>&1 1>&2 2>&3)
    conf_mysqlrpass2=$(whiptail --title "Password for MYSQL root" --passwordbox "Enter password again to confirm:" 10 80 3>&1 1>&2 2>&3)
    [ "$conf_mysqlrpass" = "$conf_mysqlrpass2" ] && break
  done

  conf_email=$(whiptail --title "Email" --inputbox "Enter email address:" 10 80 3>&1 1>&2 2>&3)

  cmd=(whiptail --separate-output --checklist "Please Select options:" 22 76 16)
  options=(1 "SSL installation" yes
           2 "Adminer installation" yes
           3 "Enable UFW" yes
           4 "Install Webmin" yes
           5 "Create password backup file" no)
  choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear
  for choice in $choices; do
    case $choice in
      1) conf_ssl_install='yes' ;;
      2) conf_install_adminer='yes' ;;
      3) conf_enable_ufw='yes' ;;
      4) conf_webmin_install='yes' ;;
      5) conf_create_pass_backup='yes' ;;
    esac
  done

  conf_http_server=$(whiptail --menu "Chose web server" 18 60 10 \
    "Apache" " - Suitable for most websites." \
    "Nginx " " - For a websites with more visits." 3>&1 1>&2 2>&3)
  if [ -z "$conf_http_server" ]; then
    echo "No option was chosen."
  fi

  conf_hostname=${conf_hostname:='N/A'}
  conf_unixuser=${conf_unixuser:='manager'}
  conf_email=${conf_email:='N/A'}
  conf_ssl_install=${conf_ssl_install:='no'}
  conf_install_adminer=${conf_install_adminer:='no'}
  conf_enable_ufw=${conf_enable_ufw:='no'}
  conf_create_pass_backup=${conf_create_pass_backup:='no'}
  conf_webmin_install=${conf_webmin_install:='no'}

  whiptail --title "Installation Summary" --scrolltext --yesno "
  Server hostname: $conf_hostname
  rootpass: $conf_rootpass
  System user username: $conf_unixuser
  System user password: $conf_unixpass
  Password for MYSQL root: $conf_mysqlrpass
  Email address: $conf_email
  Install SSL for default site: $conf_ssl_install
  Install Adminer: $conf_install_adminer
  Enable UFW firewall: $conf_enable_ufw
  Install Webmin: $conf_webmin_install
  Web server type: $conf_http_server
  Create password backup file: $conf_create_pass_backup
  " --yes-button "Install" --no-button "Enter again" 20 65
}

fn_fallback () {
  fn_input_hostname () {
    printf "${YELLOW}$lang_enter_information${NC}\n"
    printf "${YELLOW}$lang_start_step_1${NC}\n"
    while true; do
        read -p "$lang_enter_domain_name" conf_hostname
      conf_hostname=${conf_hostname:-default}
        read -p "$lang_enter_again_to_confirm" conf_hostname2
        [ "$conf_hostname" = "$conf_hostname2" ] && break
        printf "${RED}$lang_try_again${NC}\n"
    done
  }
  fn_input_rootpass () {
    printf "${YELLOW}$lang_start_step_2${NC}\n"
    while true; do
        read -s -p "$lang_enter_root_password" conf_rootpass
      conf_rootpass=${conf_rootpass:-default}
      echo
        read -s -p "$lang_enter_again_to_confirm" conf_rootpass2
      echo
        [ "$conf_rootpass" = "$conf_rootpass2" ] && break
        printf "${RED}$lang_try_again${NC}\n"
      echo
      echo
    done
  }
  fn_input_unixuser () {
    printf "${YELLOW}$lang_start_step_3${NC}\n"
    read -p "$lang_enter_unix_user_username" conf_unixuser
    conf_unixuser=${conf_unixuser:-default}
  }
  fn_input_unixpass () {
    printf "${YELLOW}$lang_start_step_4${NC}\n"
    while true; do
        read -s -p "$lang_enter_unix_user_password" conf_unixpass
      conf_unixpass=${conf_unixpass:-default}
      echo
        read -s -p "$lang_enter_again_to_confirm" conf_unixpass2
      echo
        [ "$conf_unixpass" = "$conf_unixpass2" ] && break
        printf "${RED}$lang_try_again${NC}\n"
    done
  }
  fn_input_mysqlrpass () {
    printf "${YELLOW}$lang_start_step_5${NC}\n"
    printf "${YELLOW}$lang_mysql_password_set_up${NC}\n"
    while true; do
        read -s -p "$lang_enter_mysql_root_password" conf_mysqlrpass
      conf_mysqlrpass=${conf_mysqlrpass:-default}
      echo
        read -s -p "$lang_enter_again_to_confirm" conf_mysqlrpass2
      echo
        [ "$conf_mysqlrpass" = "$conf_mysqlrpass2" ] && break
        printf "${RED}$lang_try_again${NC}\n"
    done
  }
  fn_input_email () {
    printf "${YELLOW}$lang_start_step_6${NC}\n"
    printf "${YELLOW}$lang_setting_up_email${NC}\n"
    while true; do
        read -p "$lang_enter_your_email" conf_email
        read -p "$lang_enter_again_to_confirm" conf_email2
        [ "$conf_email" = "$conf_email2" ] && conf_email=${conf_email:-webmaster@example.com} && break
        printf "${RED}$lang_try_again${NC}\n"
    done
  }
  # Choose http server
  fn_input_server_type () {
    printf "${YELLOW}$lang_start_step_7${NC}\n"
    printf "${YELLOW}$lang_install_apache_or_nginx${NC}\n"
    PS3="$lang_choose_one_of_the_folowing"
    options=("apache" "nginx")
    select conf_http_server in "${options[@]}"
    do
        case $conf_http_server in
            "apache")
                printf "$lang_you_have_chosen_apache\n"
                break
                ;;
            "nginx")
                printf "$lang_you_have_chosen_nginx\n"
                break
                ;;
            *) printf "$lang_invalid_option $REPLY\n"
            ;;
        esac
    done
  }
  [ -n "$conf_hostname" ] && printf "hostname already set to ${YELLOW}$conf_hostname${NC}, skipping user input...\n" || fn_input_hostname
  [ -n "$conf_rootpass" ] && printf "rootpass already set, skipping user input...\n" || fn_input_rootpass
  [ -n "$conf_unixuser" ] && printf "unixuser already set to ${YELLOW}$conf_unixuser${NC}, skipping user input...\n" || fn_input_unixuser
  [ -n "$conf_unixpass" ] && printf "unixpass already set, skipping user input...\n" || fn_input_unixpass
  [ -n "$conf_mysqlrpass" ] && printf "mysqlrpass already set, skipping user input...\n" || fn_input_mysqlrpass
  [ -n "$conf_email" ] && printf "email already set to ${YELLOW}$conf_email${NC}, skipping user input...\n" || fn_input_email
  [ -n "$conf_http_server" ] && printf "web_server already set to ${YELLOW}$conf_http_server${NC}, skipping user input...\n" || fn_input_server_type
}