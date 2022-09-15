fn_input_hostname () {
  printf "${YELLOW}$lang_enter_information${NC}\n"
  printf "${YELLOW}$lang_start_step_1${NC}\n"
  while true; do
      read -p "$lang_enter_domain_name" hostname
  	hostname=${hostname:-default}
      read -p "$lang_enter_again_to_confirm" hostname2
      [ "$hostname" = "$hostname2" ] && break
      printf "${RED}$lang_try_again${NC}\n"
  done
}

fn_input_rootpass () {
  printf "${YELLOW}$lang_start_step_2${NC}\n"
  while true; do
      read -s -p "$lang_enter_root_password" rootpass
  	rootpass=${rootpass:-default}
  	echo
      read -s -p "$lang_enter_again_to_confirm" rootpass2
  	echo
      [ "$rootpass" = "$rootpass2" ] && break
      printf "${RED}$lang_try_again${NC}\n"
  	echo
    echo
  done
}

fn_input_unixuser () {
  printf "${YELLOW}$lang_start_step_3${NC}\n"
  read -p "$lang_enter_unix_user_username" unixuser
  unixuser=${unixuser:-default}
}

fn_input_unixpass () {
  printf "${YELLOW}$lang_start_step_4${NC}\n"
  while true; do
      read -s -p "$lang_enter_unix_user_password" unixpass
  	unixpass=${unixpass:-default}
  	echo
      read -s -p "$lang_enter_again_to_confirm" unixpass2
  	echo
      [ "$unixpass" = "$unixpass2" ] && break
      printf "${RED}$lang_try_again${NC}\n"
  done
}

fn_input_mysqlrpass () {
  printf "${YELLOW}$lang_start_step_5${NC}\n"
  printf "${YELLOW}$lang_mysql_password_set_up${NC}\n"
  while true; do
      read -s -p "$lang_enter_mysql_root_password" mysqlrpass
  	mysqlrpass=${mysqlrpass:-default}
  	echo
      read -s -p "$lang_enter_again_to_confirm" mysqlrpass2
  	echo
      [ "$mysqlrpass" = "$mysqlrpass2" ] && break
      printf "${RED}$lang_try_again${NC}\n"
  done
}

fn_input_email () {
  printf "${YELLOW}$lang_start_step_6${NC}\n"
  printf "${YELLOW}$lang_setting_up_email${NC}\n"
  while true; do
      read -p "$lang_enter_your_email" email
      read -p "$lang_enter_again_to_confirm" email2
      [ "$email" = "$email2" ] && email=${email:-webmaster@example.com} && break
      printf "${RED}$lang_try_again${NC}\n"
  done
}

# Choose http server
fn_input_server_type () {
  printf "${YELLOW}$lang_start_step_7${NC}\n"
  printf "${YELLOW}$lang_install_apache_or_nginx${NC}\n"
  PS3="$lang_choose_one_of_the_folowing"
  options=("apache" "nginx")
  select web_server in "${options[@]}"
  do
      case $web_server in
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
