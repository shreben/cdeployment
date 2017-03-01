#!/bin/bash

#-----------------------------------------#
#     Sample app deployment script        #
#                                         #
#       Written by Siarhei Hreben         #
#                                         #
#-----------------------------------------#

# Define variables
BASE_DIR=/home/shreben/deployment
APP=sample_app
OLD="old"
CUR="current"
DIST="dist"
TEMP=/tmp
RELEASE="release-6.tar.gz"
APP_DEPLOY=/opt/jboss/jboss-as/server/jenkins_labwork8/deploy/hreben.war/

# Checking permissions on base directory
echo "Checking base directory permissions..."
if [ ! -r $BASE_DIR ]
then 
	printf "Cannot write to $BASE_DIR. Exiting..."
	exit
fi

# Checking app directory structure
echo "Checking app directory structure..."
if [ ! -d $BASE_DIR/$APP ]
then
	printf "Missing directories. Creating app directory structure...\n"
	cd $BASE_DIR
	mkdir -p $APP/{$OLD,$CUR,$DIST}
else
	for dir in $OLD $CUR $DIST
	do
		cd $BASE_DIR/$APP
		if [ ! -d $dir ]
		then
			echo "Directory $dir is missing. Creating one..."
			mkdir $dir
		fi
	done
fi

# Retrieve artefact
echo "Downloading artifact..."
cd $TEMP
wget http://nexus/repository/siarhei-hreben-raw/$RELEASE

# Deploying artefact
echo "Checking artefact consistency..."
if $(tar tf $RELEASE > /dev/null 2>&1);
then
	echo "Preparing artefact for deployment..."
	if [ -z "$(ls -A $BASE_DIR/$APP/$CUR/)" ]; then
		echo "Empty $CUR dir, nothing to move."
		mv $RELEASE $BASE_DIR/$APP/$CUR/
		tar -zxf $BASE_DIR/$APP/$CUR/$RELEASE -C $BASE_DIR/$APP/$DIST/
	else
		echo "Cleaning directories... "
		# Define old release variable
		OLD_RELEASE=`ls $BASE_DIR/$APP/$CUR/`
		rm -f $BASE_DIR/$APP/$OLD/* && mv $BASE_DIR/$APP/$CUR/$OLD_RELEASE $BASE_DIR/$APP/$OLD && mv $RELEASE $BASE_DIR/$APP/$CUR/
	        rm -f $BASE_DIR/$APP/$DIST/*
        fi
	echo "Deploying..."
	tar -zxf $BASE_DIR/$APP/$CUR/$RELEASE -C $BASE_DIR/$APP/$DIST/
	sudo cp $BASE_DIR/$APP/$DIST/* $APP_DEPLOY
else
	echo "Release archive is corrupted. Exiting."
	exit
fi

echo "Waiting for Jboss..."
sleep 15s

echo "Performing tests..."
if [ -z "$(curl -sL http://jboss/hreben | grep Sample)"]
	then
		echo "Something went wrong. Rolling back..."
		if [ -z "$(ls -A $BASE_DIR/$APP/$OLD/)" ]
		then
                	echo "It seems to be an initial release, no backups available!"
			echo "Review your code!"
			exit
		else
			rm -f $BASE_DIR/$APP/$CUR/*
			rm -f $BASE_DIR/$APP/$DIST/*
			mv $BASE_DIR/$APP/$OLD/$OLD_RELEASE $BASE_DIR/$APP/$CUR
			tar -zxf $BASE_DIR/$APP/$CUR/$RELEASE -C $BASE_DIR/$APP/$DIST/
		        sudo cp $BASE_DIR/$APP/$DIST/* $APP_DEPLOY
		fi
	else
		echo "Congratulations! Application is up and running!"
fi

 



