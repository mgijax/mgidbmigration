#!/bin/csh -f

#
# Migration for MGI Maps
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo "MGI Maps Migration..." | tee -a ${LOG}
 
#
# Use new schema product to create new table
#
${newmgddbschema}/table/MAP_create.logical >> ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/MAP_create.logical >> ${LOG}

date >> ${LOG}

