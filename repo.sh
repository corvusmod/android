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
PATCHFILE=$MAINDIR/parches.txt
PATCHDIR=$MAINDIR/parches
PATCHEXECDIR=$MAINDIR/patches

$SCRIPTDIR/projects.sh $1 $MAINDIR/default.xml

if [ -f $MAINDIR/mydefault.xml ]; then
	$SCRIPTDIR/projects.sh $1 $MAINDIR/mydefault.xml
fi

if [ "$1" = init ]; then
	cp build/core/root.mk Makefile
fi
		
#Aplicamos parches
for f in `ls $PATCHDIR`; do
	DIRP=`grep $f $PATCHFILE | cut -d " " -f 1`
	FILEP=`grep $f $PATCHFILE | cut -d " " -f 2`
	if [ ! -f $PATCHEXECDIR/$FILEP ]; then
		echo "Aplicando parche a $DIRP"
		cp $PATCHDIR/$f $DIRP/$FILEP
		cd $DIRP
		git am --signoff < $FILEP
		mv $FILEP $TOPDIR/$PATCHEXECDIR
		cd $TOPDIR
	fi
done

if [ "$1" = sync ]; then
	find . -path './roms' -prune -o -path './out' -prune -o -path '*/.git' -prune -o -path './.repo' -prune -o \! -type d -newer cambios.txt -print >> cambios.txt
fi
