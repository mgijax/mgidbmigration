#!/bin/csh -f

#
# Migration for MGI Sequences
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo "MGI Sequences Migration..." | tee -a ${LOG}
 
#
# Use new schema product to create new table
#
${newmgddbschema}/table/SEQ_create.logical >> ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/default/SEQ_bind.logical >> ${LOG}
${newmgddbschema}/index/SEQ_create.logical >> ${LOG}
${newmgddbschema}/partition/SEQ_create.logical >> ${LOG}

date >> ${LOG}

