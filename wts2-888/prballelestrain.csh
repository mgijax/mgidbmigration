#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd PRB_Allele_Strain ${MGI_LIVE}/dbutils/mgidbmigration/wts2-888/PRB_Allele_Strain.bcp "|"

${PG_MGD_DBSCHEMADIR}/index/PRB_Allele_Strain_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/PRB_Allele_Strain_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/PRB_Strain_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_User_drop.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE PRB_Allele_Strain RENAME TO PRB_Allele_Strain_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/PRB_Allele_Strain_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/autosequence/PRB_Allele_Strain_create.object | tee -a $LOG 

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into PRB_Allele_Strain
select nextval('prb_allele_strain_seq'), _allele_key, _strain_key, _createdby_key, _modifiedby_key, creation_date , modification_date
from PRB_Allele_Strain_old
;

EOSQL

${PG_MGD_DBSCHEMADIR}/index/PRB_Allele_Strain_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/comments/PRB_Allele_Strain_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/PRB_Allele_Strain_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/PRB_Strain_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from PRB_Allele_Strain_old;
select count(*) from PRB_Allele_Strain;

drop table PRB_Allele_Strain_old;
EOSQL

date |tee -a $LOG

