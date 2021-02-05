<p align="center">
  <img src="files/resources/uset-logo.png">
</p>

# USet
Server installation script

Note: The USet script is currently compatible only with Ubuntu server.

Minimum required Ubuntu version: 18.04

### Running the script

```
git clone https://github.com/sitemapxml/USet.git
cd USet
chmod +x uset
./uset
```

If you wish to save screen output you can do it simply by using tee command:

```
./uset | tee log.txt
```

Before running the script you should check if the name servers point to your server IP address. The easiest way to do it is by using `host` command:

```
host example.com
```

Which will return:

```
example.com has address 93.184.216.34
```

If you don't see your IP, or you get something like this:

```
Host example.com not found: 3(NXDOMAIN)
```
It means that DNS propagation is not complete and you probably need to wait until it's done. Configuring the server without domain name is possible, but in that case you won't be able to install `Let's Encrypt` SSL certificate.  
