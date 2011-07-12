#!/bin/sh

#
# Convert mgddbschema to mgdpostgres
#
#

cd `dirname $0` && . ../Configuration
LOG=`pwd`/$0.log
rm -rf ${LOG}

#
# migrate sybase/mgddbschema/table scripts to postgres scripts
#
#date | tee -a ${LOG}
#echo "call edit scripts..."
#${MGDPOSTGRES}/bin/editscripts.sh | tee -a ${LOG}
#echo "end edit scripts..."
#date | tee -a ${LOG}
#exit 0

#
# execute the table scripts (build tables)
#
#date | tee -a ${LOG}
#echo "call table drop..."
#${MGDPOSTGRES}/bin/table_drop.sh ${POSTGRESTABLE} | tee -a ${LOG}
#echo "end table drop..."
#echo "call table create..."
#${MGDPOSTGRES}/bin/table_create.sh ${POSTGRESTABLE} | tee -a ${LOG}
#echo "end table create..."
#date | tee -a ${LOG}
#exit 0

#
# bulk load sybase data/load into postgres
#
#date | tee -a ${LOG}
#echo "call bulkloader..."
#${MGDPOSTGRES}/bin/bulkload.sh | tee -a ${LOG}
#echo "end bulkloader..."
#date | tee -a ${LOG}

#
# execute the index scripts (build indexes)
# indexes are added by the bulkload.sh script
#
#${MGDPOSTGRES}/bin/index_create.sh ${POSTGRESINDEX} | tee -a ${LOG}

#
# execute the key
#
${MGDPOSTGRES}/bin/key_create.sh

echo "end of convertToPsql..."
date | tee -a ${LOG}
