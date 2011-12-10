#!/bin/bash
# Copyright (C) 2011 The Superteam Development Group
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#Inicializamos las variables
SCRIPTDIR=`dirname $0`
TOPDIR=`pwd`
GIT=git
MAINDIR=android
XMLFILE=$2
DefRemote=`xmllint --xpath 'string(//default/@remote)' $XMLFILE`
DefBranch=`xmllint --xpath 'string(//default/@revision)' $XMLFILE`


function getProjectList(){
	PROJECTLIST=`xmllint --xpath '//project/@path' $TOPDIR/$XMLFILE`
}

function getPath(){
	mPath=`xmllint --xpath 'string(//project[@'$1']/@path)' $XMLFILE`
}

function getName(){
	mName=`xmllint --xpath 'string(//project[@'$1']/@name)' $XMLFILE`
}

function getPath(){
	mPath=`xmllint --xpath 'string(//project[@'$1']/@path)' $XMLFILE`
}

function getRemote(){
	mRemote=`xmllint --xpath 'string(//project[@'$1']/@remote)' $XMLFILE`
	mRemote=${mRemote:=$DefRemote}
}

function getRemoteURL(){
	mRemoteURL=`xmllint --xpath 'string(//remote[@name="'$1'"]/@fetch)' $XMLFILE`
}

function getBranch(){
	mBranch=`xmllint --xpath 'string(//project[@'$1']/@revision)' $XMLFILE`
    mBranch=${mBranch#"refs/tags/"}
	mBranch=${mBranch:=$DefBranch}
}

function getUpstream(){
	mUpstream=`xmllint --xpath 'string(//project[@'$1']/@upstream)' $XMLFILE`
}

function gitPull(){
	cd $mPath
	$GIT pull
	#$GIT rebase origin/$mBranch
	cd $TOPDIR
}

function gitUpstream(){
	cd $mPath
	$GIT pull upstream $mBranch
	#$GIT rebase origin/$mBranch
	cd $TOPDIR
}

function gitClone(){
	mkdir -p $mPath
	$GIT clone $mRemoteURL$mName $mPath
	cd $mPath
	$GIT checkout $mBranch
	if [ ! -z $mUpstream ]; then
		$GIT remote add upstream git://$mUpstream.git
	fi
	cd $TOPDIR
}

function gitStatus(){
	cd $mPath
	STATUS=`$GIT status`
	if [[ "$STATUS" =~ "Changes" ]] || [[ "$STATUS" =~ "Untracked" ]]; then
		echo -e "\033[1;32m" $mPath "\033[0m"
		$GIT status
	fi
	cd $TOPDIR
}

function setEnv(){
	getPath $1
	getRemote $1
	getBranch $1
	getRemoteURL $mRemote
	getName $1
	getUpstream $1
}

getProjectList

for d in $PROJECTLIST; do
	setEnv $d
	if [ "$1" = status ]; then
		if [ -d $mPath ]; then
			gitStatus
		fi
	elif [ "$1" = init ]; then
		if [ ! -d $mPath ]; then
			gitClone
		fi
	elif [ "$1" = sync ]; then
	  	echo -e "\033[1;32m" $mPath "\033[0m"

		if [ -d $mPath ]; then
			gitPull
		else
			gitClone
		fi
	elif [ "$1" = fullsync ]; then
	  	echo -e "\033[1;32m" $mPath "\033[0m"

		if [ -d $mPath ]; then
			gitPull
			gitUpstream
		else
			gitClone
		fi
	fi
done
