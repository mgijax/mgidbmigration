#!/bin/csh -f

#
# has tr12963 branch:
# ei
# pgmgddbschema
# pgdbutilities
# mrkcacheload
# qcreports_db
# nomenload
# genemapload
# unistsload
# 
# no branch yet:
# femover
# mgd_java_api
# reports_db
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
 
#
# MRK_Marker : adding cmOffset
# MRK_Offset : removing
#
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd MRK_Offset ${MGI_LIVE}/dbutils/mgidbmigration/tr12963/MRK_Offset.bcp "|"
${PG_MGD_DBSCHEMADIR}/index/MRK_Marker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/MRK_Marker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/view_drop.sh | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.MRK_Marker DROP CONSTRAINT MRK_Marker__Organism_key_fkey CASCADE;
ALTER TABLE mgd.MRK_Marker DROP CONSTRAINT MRK_Marker__ModifiedBy_key_fkey CASCADE;
ALTER TABLE mgd.MRK_Marker DROP CONSTRAINT MRK_Marker__CreatedBy_key_fkey CASCADE;
ALTER TABLE mgd.MRK_Marker DROP CONSTRAINT MRK_Marker_pkey CASCADE;
ALTER TABLE mgd.MRK_Marker DROP CONSTRAINT MRK_Marker_pkey CASCADE;
ALTER TABLE mgd.MRK_Marker DROP CONSTRAINT MRK_Marker__Marker_Status_key_fkey CASCADE;
ALTER TABLE mgd.MRK_Marker DROP CONSTRAINT MRK_Marker__Marker_Type_key_fkey CASCADE;
ALTER TABLE MRK_Marker RENAME TO MRK_Marker_old;
ALTER TABLE mgd.MRK_Marker_old DROP CONSTRAINT MRK_Marker_pkey CASCADE;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/MRK_Marker_create.object | tee -a $LOG || exit 1

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into MRK_Marker
select m._Marker_key, m._Organism_key, m._Marker_status_key, m._Marker_Type_key,
m.symbol, m.name, m.chromosome, m.cytogeneticOffset, null,
m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from MRK_Marker_old m
where m._Organism_key != 1
;

insert into MRK_Marker
select m._Marker_key, m._Organism_key, m._Marker_status_key, m._Marker_Type_key,
m.symbol, m.name, m.chromosome, m.cytogeneticOffset, s.cmOffset,
m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from MRK_Marker_old m, MRK_Offset s
where m._Organism_key = 1
and m._Marker_key = s._Marker_key
and s.source = 0
;

ALTER TABLE mgd.MRK_Marker ADD FOREIGN KEY (_Organism_key) REFERENCES mgd.MGI_Organism DEFERRABLE;
ALTER TABLE mgd.MRK_Marker ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.MRK_Marker ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.MRK_Marker ADD FOREIGN KEY (_Marker_Status_key) REFERENCES mgd.MRK_Status DEFERRABLE;
ALTER TABLE mgd.MRK_Marker ADD FOREIGN KEY (_Marker_Type_key) REFERENCES mgd.MRK_Types DEFERRABLE;

-- obsolete/remove
DROP FUNCTION IF EXISTS MRK_updateOffset(int,int);

-- need to change int->bigint, so need to drop obsolete function
DROP FUNCTION IF EXISTS MRK_insertHistory(int,int,int,int,int,int,text,timestamp,int,int,timestamp,timestamp);

EOSQL

${PG_MGD_DBSCHEMADIR}/index/MRK_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/MRK_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/MRK_Marker_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/procedure/ALL_convertAllele_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/ALL_createWildType_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MRK_alleleWithdrawal_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MRK_deleteWithdrawal_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MRK_mergeWithdrawal_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MRK_reloadLocation_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MRK_simpleWithdrawal_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MRK_insertHistory_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/SEQ_deleteObsoleteDummy_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/VOC_deleteGOGAFRed_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/VOC_deleteGOWithdrawn_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from MRK_Marker_old;

select count(*) from MRK_Marker;

select count(*) from MRK_Marker where _Organism_key = 1 and cmOffset is null;

select m._Marker_key, m.symbol, m.cmOffset
from MRK_Marker m, MRK_Offset o
where m._Marker_key = o._Marker_key
and o.source = 0
and m.cmOffset != o.cmOffset
;

drop table mgd.MRK_Marker_old;
drop table mgd.MRK_Offset;

EOSQL

${MRKCACHELOAD}/mrklocation.csh | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/view/view_create.sh | tee -a $LOG || exit 1
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

date |tee -a $LOG

