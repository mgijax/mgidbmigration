#!/bin/csh

#
# Program: pixload.csh
#
# Original Author: Lori Corbani
#
# Purpose:
#
#	Take a directory of gif files and "load" them into
#	PixelDB.
#
# Requirements Satisfied by This Program:
#
# Usage:
#
#	pixload.csh [IMG File Directory] [output file]
#
#	example: pixload.csh data/tr4800/images/10.5dpc pix10.5dpc
#
# Envvars:
#
# Inputs:
#
#	A directory containing gif files
#
# Outputs:
#
#	An tab-delimited output file of:
#		gif filename
#		pixel DB id
#

cd `dirname $0` && source ./Configuration

setenv IMGDIRECTORY	$1
setenv OUTPUTFILE	$2

set accID=`cat $PIXELDBCOUNTER`
rm -rf $OUTPUTFILE
touch $OUTPUTFILE
echo "starting pix id: " $accID

foreach j ($IMGDIRECTORY/*.gif)
	set n=`basename $j .gif`
	echo $n
	cp $j $PIXELDBDATA/$accID.jpg
	echo "$n	$accID" >> $OUTPUTFILE
	set accID=`expr $accID + 1`
end

rm -rf $PIXELDBCOUNTER
echo $accID > $PIXELDBCOUNTER
echo "ending pix id: " $accID

