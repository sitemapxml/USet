# Change log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- option to install database management system `phpmyadmin` or ~~adminer~~
- option to install server log analizer `Webalyzer`, `GoAccess` or `Netdata`
- option to enable security headers in web server configuration
- option to enable http/2
- adding translation to `mksite` and `uninstall` script
- adding configuration file to `mksite` and `uninstall`
- saving passwords in secure file
- customise (`Yes/No`) prompt input key according to a language

---
## [2.4.0] - 2021. Jul, 6.

### Added
- Added option to configure if you want to create index.html and info.php file.

### Changed files
- main script `USet`
- `config.txt`: added options `conf_create_index_html` and `conf_create_info_php`
- language files - added folowing translation strings:
  - lang_index_html_configured
  - lang_skipping_creation_of_index_html
  - lang_info_php_configured
  - lang_skipping_creation_of_info_php

---
## [2.3.1] - 2021. Jul, 1.

### Bugfix
 - added path to `7g.conf` in `apache.conf` 

---
## [2.3.0] - 2021. Jul, 1.

### Added
- added option to install `Adminer`

### Changed
- updated configuration variables
- update language translations

---

## [2.2.0] - 2021. April, 25.

### Added
 - apache firewall installation is now conditional, depending on web server type installed. Nginx support will be added in next release.
 - added option to install 7G firewall. Support for 6G still remains.
 - added translation variable `lang_choose_apache_firewall_version` to translation files

### Changed
 - variable `lang_do_you_want_to_enable_6g_firewall` is renamed to `lang_do_you_want_to_enable_apache_firewall`
---

## [2.1.0] - 2021. April, 19.

### Added
- `config.txt` - you can now configure additional options using config file 
- automatically set mysql root password
- added language files and welcome screen screenshot
- `.editorconfig` for better portability between editors
- Downloaded Wordpress archive filename `wp_wget_filename` is now automatically calculated using `basename` 

### Removed
- removed `conf_wp_wget_filename` from `config.txt`

### Changed
- database creation string in Wordpress section - mysql "CREATE DATABASE" directive is the same for mysql version 5 and 8, so it is moved outside the condition
- renamed `conf_wp_wget_filename` -> `wp_wget_filename`

---

## [2.0.0] - 2021. February, 7

### Added
- this file - Change log will be regulary updated fron now on
- Serbian and English translation files `languages/sr.txt` and `languages/en.txt`
- translation file check - if translation file is not present English translation will be loaded
- configuration options - added `config.txt`
- a brand-new logo

### Removed
- old welcome message

### Changed
- Webmin installation is now optional
- Webmin port can be changed
- file names can be changed via configuration options
- output text coloring can be turned on and off
- if you are configurating multiple servers at once you can choose to disable welcome screen
- you can choose what packages you want to install by changing `$conf_php_extension_list` and `$conf_helper_program_list` in `config.txt`

Wordpress download url can be changes. This is useful for localised Wordpress installations. For example, if you download wordpress from this link:
- `https://de.wordpress.org/latest-de_DE.zip`, wordpress comments in the code will be on German, and if you download from this link: 
- `https://fr.wordpress.org/latest-fr_FR.zip`, comments in the code will be on French

If `$conf_wp_wget_locale` value is changed, downloaded file name must match the name in the configuration file. If you change download url to German, `$conf_wp_wget_filename` should be `latest-de_DE.zip`, if you change it to French, filename should be `latest-fr_FR.zip`.
