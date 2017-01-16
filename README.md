# Meteoric

Deploy Meteor to Ubuntu 16 servers

## How to install and update

The easiest way to install (or update) `meteoric` is using curl:

```bash
$ curl https://raw.github.com/JackAdams/meteoric.sh/master/install | sh
```

You may need to `sudo` in order for the script to symlink `meteoric` to your `/usr/local/bin`.

## How to use

Create a conf file named `meteoric.config.sh` in your project's folder, setting the following variables:

(Only the first five variables are required.)

```bash

# What's your app name?
APP_NAME=microscope

# IP or URL of the server you want to deploy to
APP_HOST=my.app.com

# What's your project's Git repo?
GIT_URL=git://github.com/TelescopeJS/Telescope.git

# If you would like to use a different branch, set it here
GIT_BRANCH=master

# If your app is not on the repository root, set this
APP_PATH=.

# If you want to deploy to a different port (default is 80)
#PORT=4000

# if you want to deploy instances to several consecutive ports -- e.g. 3000, 3001, 3002, 3003
#INSTANCES=4

# Comment this if your host is not an EC2 instance
#EC2_PEM_FILE=~/.ssh/proxynet.pem

# If you want to use a specific meteor release to deploy your app, you need to specify this
#METEOR_RELEASE=1.4.1.1

# If your repository contains several meteor app, set a unique $BUNDLE_NAME for each app to stop files/folders overwriting each other during the build process (default bundle name is 'bundle')
#BUNDLE_NAME=admin.console

# Kill the forever and node processes, and deletes the bundle directory and tar file prior to deploying
#FORCE_CLEAN=false

# If you want a different ROOT_URL, when using ssl or a load balancer for instance, set it here -- otherwise you get http://$APP_HOST ($APP_HOST as defined above)
#ROOT_URL=mycustom.url.com

# If you want something other than mongodb://localhost:27017/$APP_NAME ($APP_NAME as defined above) -- e.g. if you want to create a user for your mongo instance
#MONGO_URL=mongodb://dbuser:dbuserpassword@127.0.0.1:27017/mydb?replicaSet=rs0

# Set other environment variables (separated by spaces)
#ENVIRONMENT_VARIABLES='MONGO_OPLOG_URL=mongodb://oplogger:oploggerpassword@127.0.0.1:27017/local?authSource=admin MAIL_URL=smtp://gmailaddress%40gmail.com:gmailpassword@smtp.gmail.com:465'

```

Then just run:

```bash
$ meteoric setup

$ meteoric deploy
```

To start/restart instance(s):
```bash
meteoric start
```

If you'd like to use a different location for meteoric.config.sh, supply it as a second parameter:

```bash
$ meteoric setup /path/to/your.config.sh

$ meteoric deploy /path/to/your.config.sh
```


## Tested on

- Ubuntu 16.04

## Inspiration

This is a hacked version of [Julien Chamond's Meteoric](https://github.com/julien-c/meteoric.sh) to keep it working for recent versions of Meteor and Ubuntu 16 servers.