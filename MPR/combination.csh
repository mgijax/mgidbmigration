#!/bin/csh -f

#
# Wrapper script to create & load mginotes into MGI_Note
#
# Usage:  combination.csh
#

cd `dirname $0`

source ./Configuration

setenv NOTEMODE	load
setenv OBJECTTYPE       Genotype

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

./combinationload.py

setenv DATAFILE 	combnotetype1.rpt
setenv NOTETYPE		"Combination Type 1"
${NOTELOAD}/mginoteload.py -S${DBSERVER} -D${DBNAME} -U${DBUSER} -P${DBPASSWORDFILE} -I${DATAFILE} -M${NOTEMODE} -O${OBJECTTYPE} -T"${NOTETYPE}" >>& ${LOG}

setenv DATAFILE 	combnotetype2.rpt
setenv NOTETYPE		"Combination Type 2"
${NOTELOAD}/mginoteload.py -S${DBSERVER} -D${DBNAME} -U${DBUSER} -P${DBPASSWORDFILE} -I${DATAFILE} -M${NOTEMODE} -O${OBJECTTYPE} -T"${NOTETYPE}" >>& ${LOG}

setenv DATAFILE 	combnotetype3.rpt
setenv NOTETYPE		"Combination Type 3"
${NOTELOAD}/mginoteload.py -S${DBSERVER} -D${DBNAME} -U${DBUSER} -P${DBPASSWORDFILE} -I${DATAFILE} -M${NOTEMODE} -O${OBJECTTYPE} -T"${NOTETYPE}" >>& ${LOG}

date >> ${LOG}

