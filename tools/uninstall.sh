#!/bin/bash

filepath=$(realpath $0)
dirpath=$(dirname $filepath)
basepath=$(echo ${dirpath%/*})
me=$(basename "$0")

source "$basepath/includes/functions.inc.sh" && fn_output_coloring_on

while true
	do
	echo -e ${YELLOW}'Step (1/*)'${NC}
	read -p 'Do you want to remove Universe repository? (Yes/No): ' uninstall_universe
		case $uninstall_universe in
		[dD][aA]|[dD])
			echo 'Removing...'
			# Remove Universe repository
			add-apt-repository --remove universe
			touch /etc/apt/sources.list
			apt-get update
			add-apt-repository main
			echo -e ${GREEN}'Universe repository has been disabled!'${NC}
		break
		;;
		[nN][eE]|[nN])
	break
	;;
	*)
	echo -e ${RED}'Please answer with Yes or No.'${NC}
	;;
	esac
done

while true
	do
	echo -e ${YELLOW}'Step (2/*)'${NC}
	read -p 'Do you want to uninstall apache http server? (Yes/No): ' uninstall_ssl
		case $uninstall_ssl in
		[dD][aA]|[dD])
			echo 'Uninstalling apache2 and its components...'
			# Uninstalling apache2
			apt-get purge apache2 apache2-utils -y
			apt-get autoremove --purge -y

			# Delete remaining directories
			rm -rf /usr/sbin/apache2
			rm -rf /usr/lib/apache2
			rm -rf /etc/apache2
			rm -rf /usr/share/man/man8/apache2.8.gz
			echo -e ${GREEN}'Apache http server has been removed!'${NC}
		break
		;;
		[nN][eE]|[nN])
	break
	;;
	*)
	echo -e ${RED}'Please answer with Yes or No.'${NC}
	;;
	esac
done

while true
	do
	echo -e ${YELLOW}'Step (3/*)'${NC}
	read -p 'Do you want to remove PHP? (Yes/No): ' uninstall_php
		case $uninstall_php in
		[dD][aA]|[dD])
			echo 'Uninstalling...'
			# Removing php
			apt-get purge 'php*' -y
			apt-get autoremove -y
			apt-get autoclean -y
			echo -e ${GREEN}'PHP has been removed!'${NC}
		break
		;;
		[nN][eE]|[nN])
	break
	;;
	*)
	echo -e ${RED}'Please answer with Yes or No.'${NC}
	;;
	esac
done

while true
	do
	echo -e ${YELLOW}'Step (4/*)'${NC}
	read -p 'Do you want to uninstall MYSQL server? (Yes/No): ' uninstall_mysql
		case $uninstall_mysql in
		[dD][aA]|[dD])
			echo 'Uninstalling...'
			# Uninstalling mysql server
			systemctl stop mysql
			apt-get --yes purge mysql-server mysql-client
			apt-get --yes autoremove --purge
			apt-get autoclean

			# Delete remaining directories
			rm /etc/apparmor.d/abstractions/mysql
			rm /etc/apparmor.d/cache/usr.sbin.mysqld

			# Remove mysql history file
			rm ~/.mysql_history

			# Remove mysql history for all the users on the system
			awk -F : '{ print($6 "/.mysql_history"); }' /etc/passwd | xargs -r -d '\n' -- sudo rm -f --

			# Remove log files outside the home directory
			find / -name .mysql_history -delete
			echo -e ${GREEN}'MYSQL has been removed!'${NC}
		break
		;;
		[nN][eE]|[nN])
	break
	;;
	*)
	echo -e ${RED}'Please answer with Yes or No.'${NC}
	;;
	esac
done

while true
	do
	echo -e ${YELLOW}'Step (5/*)'${NC}
	read -p 'Do you want to disable port protection? (Yes/No): ' uninstall_ufw
		case $uninstall_ufw in
		[dD][aA]|[dD])
			echo 'Disabling...'

			# Disable UFW
			ufw --force disable
			echo -e ${GREEN}'UFW firewall disabled!'${NC}
		break
		;;
		[nN][eE]|[nN])
	break
	;;
	*)
	echo -e ${RED}'Please answer with Yes or No.'${NC}
	;;
	esac
done
