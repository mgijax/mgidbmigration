#!/bin/csh -f

#
# Usage:  vocheader.csh
#

cd `dirname $0`

source ./Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

./vocheader.py

${newmgddbschema}/table/VOC_AnnotHeader_truncate.object >>& ${LOG}
${newmgddbschema}/index/VOC_AnnotHeader_drop.object >>& ${LOG}

cat ${DBPASSWORDFILE} | bcp ${DBNAME}..VOC_AnnotHeader in vocheader.rpt -c -t"\t" -S${DBSERVER} -U${DBUSER} >>& $LOG

${newmgddbschema}/index/VOC_AnnotHeader_create.object >>& ${LOG}

date >> ${LOG}

