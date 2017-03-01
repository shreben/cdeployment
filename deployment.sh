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
RELEASE=$ARTEFACT
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
echo "Deploying artefact..."
if [ tar -tf $RELEASE ]
then
	rm -f $BASE_DIR/$APP/$OLD/*.tar.gz && mv $BASE_DIR/$APP/$CUR/*.tar.gz $BASE_DIR/$APP/$OLD && mv $RELEASE $BASE_DIR/$APP/$CUR/
	rm -rf $BASE_DIR/$APP/$DIST/* && tar -zxf $BASE_DIR/$APP/$CUR/$RELEASE -C $BASE_DIR/$APP/$DIST/
	cp $BASE_DIR/$APP/$DIST/* $APP_DEPLOY
else
	echo "Release archive is corrupted. Exiting."
	exit
fi
	

 



