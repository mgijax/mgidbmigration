#!/bin/csh -f

#
# Wrapper script to create & load mginotes into MGI_Note
#
# Usage:  allelecombination.csh
#

cd `dirname $0`

source ./Configuration

setenv NOTEMODE	load
setenv OBJECTTYPE       Genotype

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

${ALLCACHELOAD}/allelecombination.py -S${DBSERVER} -D${DBNAME} -U${DBUSER} -P${DBPASSWORDFILE} -K0

setenv DATAFILE 	allelecombnotetype1.rpt
setenv NOTETYPE		"Combination Type 1"
${NOTELOAD}/mginoteload.py -S${DBSERVER} -D${DBNAME} -U${DBUSER} -P${DBPASSWORDFILE} -I${DATAFILE} -M${NOTEMODE} -O${OBJECTTYPE} -T"${NOTETYPE}" >>& ${LOG}

setenv DATAFILE 	allelecombnotetype2.rpt
setenv NOTETYPE		"Combination Type 2"
${NOTELOAD}/mginoteload.py -S${DBSERVER} -D${DBNAME} -U${DBUSER} -P${DBPASSWORDFILE} -I${DATAFILE} -M${NOTEMODE} -O${OBJECTTYPE} -T"${NOTETYPE}" >>& ${LOG}

setenv DATAFILE 	allelecombnotetype3.rpt
setenv NOTETYPE		"Combination Type 3"
${NOTELOAD}/mginoteload.py -S${DBSERVER} -D${DBNAME} -U${DBUSER} -P${DBPASSWORDFILE} -I${DATAFILE} -M${NOTEMODE} -O${OBJECTTYPE} -T"${NOTETYPE}" >>& ${LOG}

date >> ${LOG}

