#!/bin/csh -f

#
# Usage:  mutantescell.csh
#

cd `dirname $0`

source ./Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

./mutantescell.py

${newmgddbschema}/index/ALL_CellLine_drop.object >>& ${LOG}

cat ${DBPASSWORDFILE} | bcp ${DBNAME}..ALL_CellLine in igtc.cell -c -t"\t" -S${DBSERVER} -U${DBUSER} >>& $LOG
cat ${DBPASSWORDFILE} | bcp ${DBNAME}..ACC_Accession in igtc.acc -c -t"\t" -S${DBSERVER} -U${DBUSER} >>& $LOG

${newmgddbschema}/index/ALL_CellLine_create.object >>& ${LOG}

date >> ${LOG}

