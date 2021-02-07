# Change log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- option to install database management system `phpmyadmin` or `adminer`
- option to install server log analizer `Webalyzer`, `GoAccess` or `Netdata`
- option to enable security headers in web server configuration
- option to enable http/2
- adding translation to `mksite` and `uninstall` script
- adding configuration file to `mksite` and `uninstall`
- saving passwords in secure file
- customise (`Yes/No`) prompt input key according to a language

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
