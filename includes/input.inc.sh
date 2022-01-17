fn_input_hostname () {
  echo -e ${YELLOW}"$lang_enter_information"${NC}
  echo
  echo -e ${YELLOW}"$lang_start_step_1"${NC}
  while true; do
      read -p "$lang_enter_domain_name" hostname
  	hostname=${hostname:-default}
      read -p "$lang_enter_again_to_confirm" hostname2
      [ "$hostname" = "$hostname2" ] && break
      echo -e ${RED}"$lang_try_again"${NC}
  done
}

fn_input_rootpass () {
  echo -e ${YELLOW}"$lang_start_step_2"${NC}
  while true; do
      read -s -p "$lang_enter_root_password" rootpass
  	rootpass=${rootpass:-default}
  	echo
      read -s -p "$lang_enter_again_to_confirm" rootpass2
  	echo
      [ "$rootpass" = "$rootpass2" ] && break
      echo -e ${RED}"$lang_try_again"${NC}
  	echo
    echo
  done
}

fn_input_unixuser () {
  echo -e ${YELLOW}"$lang_start_step_3"${NC}
  read -p "$lang_enter_unix_user_username" unixuser
  unixuser=${unixuser:-default}
}

fn_input_unixpass () {
  echo -e ${YELLOW}"$lang_start_step_4"${NC}
  while true; do
      read -s -p "$lang_enter_unix_user_password" unixpass
  	unixpass=${unixpass:-default}
  	echo
      read -s -p "$lang_enter_again_to_confirm" unixpass2
  	echo
      [ "$unixpass" = "$unixpass2" ] && break
      echo -e ${RED}"$lang_try_again"${NC}
  	echo
    echo
  done
}

fn_input_mysqlrpass () {
  echo -e ${YELLOW}"$lang_start_step_5"${NC}
  echo -e ${YELLOW}"$lang_mysql_password_set_up"${NC}
  while true; do
      read -s -p "$lang_enter_mysql_root_password" mysqlrpass
  	mysqlrpass=${mysqlrpass:-default}
  	echo
      read -s -p "$lang_enter_again_to_confirm" mysqlrpass2
  	echo
      [ "$mysqlrpass" = "$mysqlrpass2" ] && break
      echo -e ${RED}"$lang_try_again"${NC}
  	echo
    echo
  done
}

fn_input_email () {
  echo -e ${YELLOW}"$lang_start_step_6"${NC}
  echo -e ${YELLOW}"$lang_setting_up_email"${NC}
  while true; do
      read -p "$lang_enter_your_email" email
      read -p "$lang_enter_again_to_confirm" email2
      [ "$email" = "$email2" ] && email=${email:-webmaster@example.com} && break
      echo -e ${RED}"$lang_try_again"${NC}
  	echo
    echo
  done
}

# Choose http server
fn_input_server_type () {
  echo -e ${YELLOW}"$lang_start_step_7"${NC}
  echo -e ${YELLOW}"$lang_install_apache_or_nginx"${NC}
  PS3="$lang_choose_one_of_the_folowing"
  options=("apache" "nginx")
  select web_server in "${options[@]}"
  do
      case $web_server in
          "apache")
              echo -e "$lang_you_have_chosen_apache"
              break
              ;;
          "nginx")
              echo -e "$lang_you_have_chosen_nginx"
              break
              ;;
          *) echo -e "$lang_invalid_option $REPLY"
          ;;
      esac
  done
}
