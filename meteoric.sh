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

if [ -z "$REPO_NAME" ]; then
    EXTRACTION_TARGET=./
	LOG_TARGET=''
	BUNDLE_DIRECTORY_NAME=bundle
	REPO_NAME=$APP_NAME
	APP_REPO_NAME=$APP_NAME
else
	EXTRACTION_TARGET=$APP_NAME
	LOG_TARGET=$APP_NAME/
	BUNDLE_DIRECTORY_NAME=$APP_NAME/bundle
	if [ -z "$APP_REPO_NAME" ]; then
		echo 'APP_REPO_NAME must be set when REPO_NAME is set';
		exit 1;
	fi;
fi

if [ -z "$ENVIRONMENT_VARIABLES" ]; then
	ENVIRONMENT='';
else
	ENVIRONMENT=$ENVIRONMENT_VARIABLES;
fi

if [ -z "$NODE_VERSION" ]; then
	NODE_VERSION='4.5.0';
fi

if [ -z "$APP_PATH" ]; then
	APP_PATH="."
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
sudo git clone $GIT_URL $REPO_NAME;
cd $REPO_NAME;
cd $APP_PATH;
sudo meteor build $APP_DIR/$BUNDLE_DIRECTORY_NAME.tgz $METEOR_OPTIONS;
cd $APP_DIR;
sudo mkdir -p $BUNDLE_DIRECTORY_NAME;
sudo tar -zxvf $BUNDLE_DIRECTORY_NAME.tgz/$APP_REPO_NAME.tar.gz -C $EXTRACTION_TARGET;
cd $BUNDLE_DIRECTORY_NAME/programs/server;
sudo npm install;
"

if [ -z "$GIT_BRANCH" ]; then
	GIT_BRANCH="master"
fi

START="
cd $APP_DIR;
echo Stopping forever;
sudo forever stop $BUNDLE_DIRECTORY_NAME/main.js;
echo Starting forever;

for ((CURRENT_PORT=$MIN_PORT; CURRENT_PORT<=$MAX_PORT; CURRENT_PORT++));
do
COMMAND='sudo PORT='\$CURRENT_PORT' ROOT_URL=$ROOT_URL MONGO_URL=$MONGO_URL $ENVIRONMENT forever start -o '$LOG_TARGET'stdout.log -e '$LOG_TARGET'stderr.log $BUNDLE_DIRECTORY_NAME/main.js';
echo \$COMMAND;
eval "\$COMMAND";
done
	
# sudo -E forever start $BUNDLE_DIRECTORY_NAME/main.js;
"

DEPLOY="
cd $APP_DIR;
cd $REPO_NAME;
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
sudo meteor build $APP_DIR/$BUNDLE_DIRECTORY_NAME.tgz $METEOR_OPTIONS --unsafe-perm;

cd $APP_DIR;
echo Unpacking ...;
sudo tar -zxvf $BUNDLE_DIRECTORY_NAME.tgz/$APP_REPO_NAME.tar.gz -C $EXTRACTION_TARGET;

if [ "$FORCE_CLEAN" == "true" ]; then
	cd $BUNDLE_DIRECTORY_NAME/programs/server;
	sudo npm install;
	cd $APP_DIR;
fi;
"

DEPLOY+=$START

case "$1" in
setup)
	ssh $SSH_OPT $SSH_HOST $SETUP
	;;
deploy)
	ssh $SSH_OPT $SSH_HOST $DEPLOY
	;;
start)
	ssh $SSH_OPT $SSH_HOST $START
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

