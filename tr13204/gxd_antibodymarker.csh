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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_AntibodyMarker ${MGI_LIVE}/dbutils/mgidbmigration/tr13204/GXD_AntibodyMarker.bcp "|"
${PG_MGD_DBSCHEMADIR}/index/GXD_AntibodyMarker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_AntibodyMarker_View_drop.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.GXD_AntibodyMarker DROP CONSTRAINT GXD_AntibodyMarker_pkey CASCADE;
ALTER TABLE mgd.GXD_AntibodyMarker DROP CONSTRAINT GXD_AntibodyMarker__Antibody_key_fkey CASCADE;
ALTER TABLE mgd.GXD_AntibodyMarker DROP CONSTRAINT GXD_AntibodyMarker__Marker_key_fkey CASCADE;
ALTER TABLE GXD_AntibodyMarker RENAME TO GXD_AntibodyMarker_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/GXD_AntibodyMarker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_AntibodyMarker_create.object | tee -a $LOG || exit 1

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into GXD_AntibodyMarker
select nextval('gxd_antibodymarker_seq'), m._Antibody_key, m._Marker_key, m.creation_date, m.modification_date
from GXD_AntibodyMarker_old m
;

ALTER TABLE mgd.GXD_AntibodyMarker ADD PRIMARY KEY (_AntibodyMarker_key);
ALTER TABLE mgd.GXD_AntibodyMarker ADD FOREIGN KEY (_Antibody_key) REFERENCES mgd.GXD_Antibody ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_AntibodyMarker ADD FOREIGN KEY (_Marker_key) REFERENCES mgd.MRK_Marker ON DELETE CASCADE DEFERRABLE;

EOSQL

${PG_MGD_DBSCHEMADIR}/index/GXD_AntibodyMarker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MRK_updateKeys_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_Antibody_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_AntibodyMarker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_AntibodyMarker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_AntibodyMarker_View_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from GXD_AntibodyMarker_old;

select count(*) from GXD_AntibodyMarker;

drop table mgd.GXD_AntibodyMarker_old;

EOSQL

date |tee -a $LOG

