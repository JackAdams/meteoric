# What's your app name?
APP_NAME=microscope

# IP or URL of the server you want to deploy to
APP_HOST=my.app.com

# What's your project's Git repo?
GIT_URL=git://github.com/SachaG/Microscope.git

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