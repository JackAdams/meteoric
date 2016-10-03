#!/bin/bash

if [[ -n "$2" ]]; then
	source $2
else
	PWD=`pwd`
	source "$PWD/meteoric.config.sh"
fi

if [ -z "$GIT_URL" ]; then
	echo "You need to create a conf file named meteoric.config.sh"
	exit 1
fi

###################
# You usually don't need to change anything here –
# You should modify your meteoric.config.sh file instead.
#

APP_DIR=/home/meteor

if [ -z "$ROOT_URL" ]; then
	ROOT_URL=http://$APP_HOST
fi

if [ -z "$PORT" ]; then
	PORT=80;
fi

if [ -z "$INSTANCES" ]; then
	INSTANCE_COUNT=1;
else
	INSTANCE_COUNT=$INSTANCES;
fi

MIN_PORT=$PORT;
MAX_PORT=$PORT+$INSTANCE_COUNT-1;

if [ -z "$MONGO_URL" ]; then
	MONGO_URL=mongodb://localhost:27017/$APP_NAME
fi

if [ -z "$METEOR_RELEASE" ]; then
	METEOR_OPTIONS=""
else
	METEOR_OPTIONS="--release $METEOR_RELEASE"
fi

if [ -z "$EC2_PEM_FILE" ]; then
	SSH_HOST="root@$APP_HOST" SSH_OPT=""
else
	SSH_HOST="ubuntu@$APP_HOST" SSH_OPT="-i $EC2_PEM_FILE"
fi

if [ -z "$BUNDLE_NAME" ]; then
	BUNDLE_DIRECTORY_NAME=bundle
else
	BUNDLE_DIRECTORY_NAME=$BUNDLE_NAME
fi

if [ -z "$ENVIRONMENT_VARIABLES" ]; then
	ENVIRONMENT='';
else
	ENVIRONMENT=$ENVIRONMENT_VARIABLES;
fi

if [ -z "$NODE_VERSION" ]; then
	NODE_VERSION='4.5.0';
fi

SETUP="
sudo apt-get -qq update;
sudo apt-get install -y git;
if [ "$SETUP_MONGO" == "true" ]; then
	sudo apt-get install -y mongodb;
fi;
sudo apt-get install -y nodejs npm;
sudo npm install -g n;
n $NODE_VERSION;
node --version;
sudo npm install -g forever;
curl https://install.meteor.com | /bin/sh;
sudo mkdir -p $APP_DIR;
cd $APP_DIR;
pwd;
sudo git clone $GIT_URL $APP_NAME;
cd $APP_NAME;
cd $APP_PATH;
sudo meteor build ../$BUNDLE_DIRECTORY_NAME.tgz $METEOR_OPTIONS;
cd ..;
sudo tar -zxvf $BUNDLE_DIRECTORY_NAME.tgz/$APP_NAME.tar.gz;
cd $BUNDLE_DIRECTORY_NAME/programs/server;
sudo npm install;
"

if [ -z "$APP_PATH" ]; then
	APP_PATH="."
fi

if [ -z "$GIT_BRANCH" ]; then
	GIT_BRANCH="master"
fi

DEPLOY="
cd $APP_DIR;
cd $APP_NAME;
echo Updating codebase;
sudo git fetch origin;
sudo git checkout $GIT_BRANCH;
sudo git pull;
cd $APP_PATH;
if [ "$FORCE_CLEAN" == "true" ]; then
    echo Killing forever and node;
    sudo killall nodejs;
    echo Cleaning bundle files;
    sudo rm -rf ../$BUNDLE_DIRECTORY_NAME > /dev/null 2>&1;
    sudo rm -rf ../$BUNDLE_DIRECTORY_NAME.tgz > /dev/null 2>&1;
fi;
echo Creating new bundle. This may take a few minutes;
sudo meteor build ../$BUNDLE_DIRECTORY_NAME.tgz $METEOR_OPTIONS;

cd ..;
echo Unpacking ...;
sudo tar -zxvf $BUNDLE_DIRECTORY_NAME.tgz/$APP_NAME.tar.gz;

if [ "$FORCE_CLEAN" == "true" ]; then
	cd $BUNDLE_DIRECTORY_NAME/programs/server;
	sudo npm install;
	cd ../../..;
fi;

echo Stopping forever;
sudo forever stopall;
echo Starting forever;

for ((CURRENT_PORT=$MIN_PORT; CURRENT_PORT<=$MAX_PORT; CURRENT_PORT++));
do
COMMAND='sudo PORT='\$CURRENT_PORT' ROOT_URL=$ROOT_URL MONGO_URL=$MONGO_URL $ENVIRONMENT forever start -o stdout.log -e stderr.log $BUNDLE_DIRECTORY_NAME/main.js';
echo \$COMMAND;
eval "\$COMMAND";
done
	
# sudo -E forever start $BUNDLE_DIRECTORY_NAME/main.js;
"

case "$1" in
setup)
	ssh $SSH_OPT $SSH_HOST $SETUP
	;;
deploy)
	ssh $SSH_OPT $SSH_HOST $DEPLOY
	;;
*)
	cat <<ENDCAT
meteoric [action]

Available actions:

setup   - Install a meteor environment on a fresh Ubuntu server
deploy  - Deploy the app to the server
ENDCAT
	;;
esac

