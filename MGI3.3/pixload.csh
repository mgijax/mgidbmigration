#!/bin/csh

#
# Program: pixload.csh
#
# Original Author: Lori Corbani
#
# Purpose:
#
#	Take a directory of gif files and "load" them into PixelDB.
#
# Requirements Satisfied by This Program:
#
# Usage:
#
#	pixload.csh [IMG File Directory] [output file]
#
#	example: pixload.csh /usr/local/mgi/live/wi/www/images/mlc pixmlc.txt
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

setenv OUTPUTFILE	pixmlc.txt

set accID=`cat ${PIXELDBCOUNTER}`
rm -rf ${OUTPUTFILE}
touch ${OUTPUTFILE}
echo "starting pix id: " $accID

foreach j (${IMGDIRECTORY}/*.jpg)
	set n=`basename $j`
	echo $n
	cp ${n} ${PIXELDBDATA}/$accID.jpg
	echo "$n	$accID" >> ${OUTPUTFILE}
	set accID=`expr $accID + 1`
end

#rm -rf ${PIXELDBCOUNTER}
#echo $accID > ${PIXELDBCOUNTER}
echo "ending pix id: " $accID

