#!/bin/csh -x -f

#
# Drop and re-create database keys
#
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a  ${LOG}

#
# drop/recreate keys so non-SNP table foreign keys are set
# drop and recreate SP SEQ_createDummy so ${DBNAME} is set properly
#

echo "drop/recreate keys" | tee -a  ${LOG}
${newmgddbschema}/key/key_drop.csh | tee -a  ${LOG}
${newmgddbschema}/key/key_create.csh | tee -a  ${LOG}

echo "drop/recreate procedure/SEQ_createDummy" | tee -a  ${LOG}
${newmgddbschema}/procedure/SEQ_createDummy_drop.object
${newmgddbschema}/procedure/SEQ_createDummy_create.object

date | tee -a  ${LOG}

