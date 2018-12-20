#!/bin/csh -f

#
# adds ALL_Variant_* tables to database
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
 
echo "Adding ALL_Variant_* tables to ${MGD_DBSERVER}..${MGD_DBNAME}" 

# 1. add ALL_Variant_* tables
# 2. add autosequences for primary keys of ALL_Variant_* tables
# 3. add comments for ALL_Variant_* tables
# 4. add indexes for ALL_Variant_* tables
# 5. add keys on ALL_Variant_* tables
# 6. add keys from ALL_Variant_* tables to pre-existing tables

${PG_MGD_DBSCHEMADIR}/table/ALL_Variant_Effect_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/ALL_Variant_Sequence_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/ALL_Variant_Type_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/ALL_Variant_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/ALL_Variant_Effect_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/ALL_Variant_Sequence_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/ALL_Variant_Type_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/ALL_Variant_drop.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/table/ALL_Variant_Effect_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/ALL_Variant_Sequence_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/ALL_Variant_Type_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/ALL_Variant_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/ALL_Variant_Effect_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/ALL_Variant_Sequence_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/ALL_Variant_Type_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/ALL_Variant_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/ALL_Variant_Effect_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/ALL_Variant_Sequence_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/ALL_Variant_Type_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/ALL_Variant_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/ALL_Variant_Effect_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/ALL_Variant_Sequence_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/ALL_Variant_Type_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/ALL_Variant_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/ALL_Variant_Effect_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/ALL_Variant_Sequence_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/ALL_Variant_Type_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/ALL_Variant_create.object | tee -a $LOG || exit 1


cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0

`grep ALL_Variant ${PG_MGD_DBSCHEMADIR}/key/ALL_Allele_create.object`
`grep ALL_Variant ${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object`
`grep ALL_Variant ${PG_MGD_DBSCHEMADIR}/key/PRB_Strain_create.object`
`grep ALL_Variant ${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object`

EOSQL

#drop table VAR_Effect;
#drop table VAR_Sequence;
#drop table VAR_Type;
#drop table VAR_Variant;

date |tee -a $LOG
