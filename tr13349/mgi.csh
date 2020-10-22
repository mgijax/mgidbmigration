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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd MGI_Organism_MGIType ${MGI_LIVE}/dbutils/mgidbmigration/tr13349/MGI_Organism_MGIType.bcp "|"

${PG_MGD_DBSCHEMADIR}/index/MGI_Organism_MGIType_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/MGI_Organism_MGIType_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_Organism_MGIType_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_Organism_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/ACC_MGIType_drop.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.MGI_Organism_MGIType DROP CONSTRAINT MGI_Organism_MGIType__ModifiedBy_key_fkey CASCADE;
ALTER TABLE mgd.MGI_Organism_MGIType DROP CONSTRAINT MGI_Organism_MGIType__CreatedBy_key_fkey CASCADE;
ALTER TABLE mgd.MGI_Organism_MGIType DROP CONSTRAINT MGI_Organism_MGIType__ReferenceType_key_fkey CASCADE;
ALTER TABLE MGI_Organism_MGIType RENAME TO MGI_Organism_MGIType_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/MGI_Organism_MGIType_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/MGI_Organism_MGIType_create.object | tee -a $LOG || exit 1

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into MGI_Organism_MGIType
select nextval('mgi_organism_mgitype_seq'), m._organism_key, m._mgitype_key, m.sequenceNum,
m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from MGI_Organism_MGIType_old m
;

EOSQL

${PG_MGD_DBSCHEMADIR}/key/MGI_Organism_MGIType_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_Organism_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/ACC_MGIType_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/MGI_Organism_MGIType_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from MGI_Organism_MGIType_old;
select count(*) from MGI_Organism_MGIType;

drop table mgd.MGI_Organism_MGIType_old;

EOSQL

date |tee -a $LOG

