#!/bin/csh -f

#
# has tr12963 branch:
# ei
# pgmgddbschema
# pgdbutilities
# nomenload
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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd MRK_History ${MGI_LIVE}/dbutils/mgidbmigration/tr12963/MRK_History.bcp "|"
${PG_MGD_DBSCHEMADIR}/index/MRK_History_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/view_drop.sh | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.MRK_History DROP CONSTRAINT MRK_History__Refs_key_fkey CASCADE;
ALTER TABLE mgd.MRK_History DROP CONSTRAINT MRK_History__ModifiedBy_key_fkey CASCADE;
ALTER TABLE mgd.MRK_History DROP CONSTRAINT MRK_History__CreatedBy_key_fkey CASCADE;
ALTER TABLE mgd.MRK_History DROP CONSTRAINT MRK_History__Marker_EventReason_key_fkey CASCADE;
ALTER TABLE mgd.MRK_History DROP CONSTRAINT MRK_History__Marker_Event_key_fkey CASCADE;
ALTER TABLE mgd.MRK_History DROP CONSTRAINT MRK_History_pkey CASCADE;
ALTER TABLE mgd.MRK_History DROP CONSTRAINT MRK_History__Marker_key_fkey CASCADE;
ALTER TABLE mgd.MRK_History DROP CONSTRAINT MRK_History__History_key_fkey CASCADE;
ALTER TABLE MRK_History RENAME TO MRK_History_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/MRK_History_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/MRK_History_create.object | tee -a $LOG || exit 1

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into MRK_History
select nextval('mrk_history_seq'), m._Marker_key, m._Marker_Event_key, m._Marker_EventReason_key,
m._History_key, m._Refs_key, m.sequenceNum, m.name, m.event_date,
m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from MRK_History_old m
;

ALTER TABLE mgd.MRK_History ADD FOREIGN KEY (_Refs_key) REFERENCES mgd.BIB_Refs DEFERRABLE;
ALTER TABLE mgd.MRK_History ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.MRK_History ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.MRK_History ADD FOREIGN KEY (_Marker_EventReason_key) REFERENCES mgd.MRK_EventReason DEFERRABLE;
ALTER TABLE mgd.MRK_History ADD FOREIGN KEY (_Marker_Event_key) REFERENCES mgd.MRK_Event DEFERRABLE;
ALTER TABLE mgd.MRK_History ADD PRIMARY KEY (_Marker_key, sequenceNum);
ALTER TABLE mgd.MRK_History ADD FOREIGN KEY (_History_key) REFERENCES mgd.MRK_Marker ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.MRK_History ADD FOREIGN KEY (_Marker_key) REFERENCES mgd.MRK_Marker ON DELETE CASCADE DEFERRABLE;

EOSQL

${PG_MGD_DBSCHEMADIR}/index/MRK_History_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MGI_resetSequenceNum_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MRK_copyHistory_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MRK_insertHistory_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MRK_mergeWithdrawal_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MRK_reloadReference_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MRK_simpleWithdrawal_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/MRK_History_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_History_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from MRK_History_old;

select count(*) from MRK_History;

drop table mgd.MRK_History_old;

EOSQL

date |tee -a $LOG

