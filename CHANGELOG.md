# Change log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
Please take a look at `Ideas` and `Todo` sections on [the project page](https://github.com/users/sitemapxml/projects/1/views/1).

---
## [3.0] - 2022. October, 9.
This is the biggest update from the beginning of this project, and I'm happy to share details with you.

In the previous release, the project started to become cluttered, and every new feature was making more mess.<br>
The main goal in this release was to make project source code easier to maintain, so new features can be easily added without adding complexity.
This is the reason, why the project has been split up in few different directories, which holds parts of the "main script".
Detailed explanation of the project structure, and the concept overall, will soon be described [in the wiki](https://github.com/sitemapxml/USet/wiki), which would serve as place for official documentation.

Apart from this, there are many new features which were added, so the user can easily adapt behavior of the script to its specific needs.

Here is the complete list of features that were added and are now officially available:

### Added
 - full support for command line arguments <br>
   The script can now be fully customized by passing appropriate options, or by editing `config/default.conf` file.<br>
   Please, note that command line options have greater priority upon options defined inside the configuration file. In other words, command line options would overwrite settings inside configuration file, if they are defined.
 - existing installation detection <br>
   The approach here it rather simple but effective. While configuring the server first time, the `uset.lock` file will be created inside `/etc/` directory, so if the user accidentally run the script again (after the initial configuration was finished), the installation will simply check if file exist, and abort if file is present. This behavior can be disabled by passing `--lock-ignore yes` option. <br>
   If you would like to disable creation of lock file, you can do so by using `--lock-create no` option.
 - package lists <br>
   There is a separate configuration file `config/pkg-list.conf` which holds lists of packages to be installed. You can edit it, to customize list of packages to be installed, or you can specify full list of packages by using option `--packages` and `--php-extensions`.
 - custom user scripts <br>
   Installation process can now be customized for any specific environment, by using custom scripts. Any additional code that has to be executed, can be added in one of two files inside `user/` directory, `pre-install.sh` and `post-install.sh`. As the names suggest, one is executed before installation process, and another is executed after installation has finished. Code inside these two files should be written in `bash`, and is automatically executed by default. Those two files can be excluded by using `--preinstall-disable yes` and `--postinstall-disable yes` options.
 - debug option <br>
   There is also an option to show all the arguments passed to a script with their values and corresponding variables.
   It can be set to one of three states:
    - args - Show only command line arguments with their values
    - vars - Show only variables with their values
    - full - Show both arguments and variables with their values

   Note that this options show both default values defined inside configuration file, and values that were set by using command line options, so, some arguments will have value no matter if you were not set them.
 - conditional interactive input <br>
   If all the variables necessary for installation are set, you wouldn't see any interactive input. If some of they are missing (for example, server host name), you will see an interactive prompt asking you to enter the target value.
 - provisioning profiles <br>
   This feature is prepared for one of the next minor releases, but is not available at a time. It will provide an option to configure the server by using predefined default values located in configuration files under `profiles/` directory.
 - full multi-language support <br>
  Any part of the script can now be translated. Translations are split in three different groups of files inside `languages/` directory.
    - The translation files inside `help/` subdirectory are reserved for help message displayed with `--help` option.
    - Files inside `welcome/` subdirectory holds welcome message in different languages.
    - The text files located in main translation directory (`languages/`) are translation strings used for everything else.

    Translations can be set by using `--language` option. The translations should be saved under two-letter code, which can be passed as value for language option, for example `-language eo`. If a translation file for the language you select does not exist, the script will fall back to `en`.
    The same stands for welcome and help message. If you make translation of only welcome message and select your language, then the welcome message would show up in your language, but all other messages would show in English.

 - additional tools <br>
  The `tools/` directory holds some useful tools that were used while developing this project, and will also be used in the future.
  Currently, there are three scripts insides:
    - uninstall script (`uninstall.sh`), that was used for testing purposes
    - `arglist.sh`, which will generate a list of available arguments defined inside `includes/arglist.inc.sh` file, and
    - `varlist.sh`, which will make list of available configuration variables, defined inside `arglist.inc.sh`, or list of variables with default values defined inside main configuration file (`config/default.conf`).

### Removed
 - WordPress <br>
   WordPress has been removed from installation process. This is not a WordPress install script. It might be added as a plugin.
 - nG Firewall <br>
   6g and 7g firewall are removed for now. They still can be easily added manually.
 - `mksite` script has been removed <br>
   You can expect something better in the future.

### Modified
 - Project directory structure
 - There are no prompts interrupting installation process, like before
 - Welcome screen is using `whiptail` utility, as it is more convenient for long messages <br>
   Welcome message can be skipped by using option `--welcome no`
 - There are no "mandatory" things like before <br>
   Anything can be disabled or enabled, to tailor specific needs of any user.

---
## [2.4.0] - 2021. Jul, 6.

### Added
- Added option to configure if you want to create index.html and info.php file.

### Changed files
- main script `USet`
- `config.txt`: added options `conf_create_index` and `conf_create_phpinfo`
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
