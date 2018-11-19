#!/bin/csh -f

#
# adds VAR_* tables to database
#


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
echo "Adding VAR_* tables to ${MGD_DBSERVER}..${MGD_DBNAME}" 

# 1. add VAR_* tables
# 2. add comments for VAR_* tables
# 3. add indexes for VAR_* tables
# 4. add keys on VAR_* tables
# 5. add keys from VAR_* tables to pre-existing tables

${PG_MGD_DBSCHEMADIR}/table/VAR_create.logical | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/comments/VAR_Effect_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/VAR_Sequence_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/VAR_Type_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/VAR_Variant_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/index/VAR_create.logical | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/VAR_create.logical | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0

`grep VAR_ ${PG_MGD_DBSCHEMADIR}/key/ALL_Allele_create.object`
`grep VAR_ ${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object`
`grep VAR_ ${PG_MGD_DBSCHEMADIR}/key/PRB_Strain_create.object`
`grep VAR_ ${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object`

EOSQL

date |tee -a $LOG
