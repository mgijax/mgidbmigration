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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd PRB_Marker ${MGI_LIVE}/dbutils/mgidbmigration/tr13204/PRB_Marker.bcp "|"

${PG_MGD_DBSCHEMADIR}/index/PRB_Marker_drop.object | tee -a $LOG 

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.PRB_Marker DROP CONSTRAINT PRB_Marker_pkey CASCADE;
ALTER TABLE mgd.PRB_Marker DROP CONSTRAINT PRB_Marker__Probe_key_fkey CASCADE;
ALTER TABLE mgd.PRB_Marker DROP CONSTRAINT PRB_Marker__Marker_key_fkey CASCADE;
ALTER TABLE mgd.PRB_Marker DROP CONSTRAINT PRB_Marker__Refs_key_fkey CASCADE;
ALTER TABLE PRB_Marker RENAME TO PRB_Marker_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/PRB_Marker_create.object | tee -a $LOG || exit 1

# autosequence
${PG_MGD_DBSCHEMADIR}/autosequence/PRB_Marker_create.object | tee -a $LOG || exit 1

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into PRB_Marker
select nextval('prb_marker_seq'), m._Probe_key, m._Marker_key, m._Refs_key, m.relationship, m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from PRB_Marker_old m
;

EOSQL

${PG_MGD_DBSCHEMADIR}/key/PRB_Marker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_Refs_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_User_drop.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/index/PRB_Marker_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/procedure/MRK_updateKeys_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/PRB_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_Refs_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/view/PRB_Marker_View_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from PRB_Marker_old;
select count(*) from PRB_Marker;

--drop table mgd.PRB_Marker_old;

EOSQL

date |tee -a $LOG

