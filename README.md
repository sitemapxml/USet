<p align="center">
  <img src="files/resources/images/uset-logo.png">
</p>

# USet
Server configuration script

> IMPORTANT NOTICE: Version 2.0 is here! 
> There are many changes and improvements in this release, but the two biggest are ability to translate interface and configuration options for those with specific needs. 
> You can check [Change Log](./CHANGELOG.md) to find out details. 

Minimum required Ubuntu version: 18.04

### Running the script

```
git clone https://github.com/sitemapxml/uset.git
cd uset
chmod +x uset
./uset
```
[![asciicast](https://asciinema.org/a/399414.svg)](https://asciinema.org/a/399414)

After running the script, you should see welcome screen like this:
<p align="center">
  <img src="files/resources/images/screenshot-welcome.jpg">
</p>

If you want to save screen output you can do it simply by using tee command:

```
./uset | tee log.txt
```
If you do so, it is advisable to turn off screen coloring by changing `$conf_disable_colors` to `true`

Before running the script you should check if the name servers point to your server IP address. The easiest way to do it, is by using `host` command:

```
host example.com
```

Which will return:
`example.com has address 93.184.216.34`

If you don't see your IP, or you get something like this: `Host example.com not found: 3(NXDOMAIN)`

It means that DNS propagation is not complete and you probably need to wait until it's done. Configuring the server without domain name is possible, but in that case you won't be able to install `Let's Encrypt` SSL certificate.

