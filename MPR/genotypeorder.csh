#!/bin/csh -f

#
# Wrapper script to create & load mginotes into MGI_Note
#
# Usage:  genotypeorder.csh
#

cd `dirname $0`

source ./Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

./genotypeorder.py

${newmgddbschema}/table/GXD_AlleleGenotype_truncate.object >>& ${LOG}
${newmgddbschema}/index/GXD_AlleleGenotype_drop.object >>& ${LOG}

cat ${DBPASSWORDFILE} | bcp ${DBNAME}..GXD_AlleleGenotype in genotypeorder.rpt -c -t\| -S${DBSERVER} -U${DBUSER} >>& $LOG

${newmgddbschema}/index/GXD_AlleleGenotype_create.object >>& ${LOG}

date >> ${LOG}

