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
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_AssayNote ${MGI_LIVE}/dbutils/mgidbmigration/tr13204/GXD_AssayNote.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_GelLaneStructure ${MGI_LIVE}/dbutils/mgidbmigration/tr13204/GXD_GelLaneStructure.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_InSituResultImage ${MGI_LIVE}/dbutils/mgidbmigration/tr13204/GXD_InSituResultImage.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_ISResultStructure ${MGI_LIVE}/dbutils/mgidbmigration/tr13204/GXD_ISResultStructure.bcp "|"

${PG_MGD_DBSCHEMADIR}/index/GXD_AntibodyMarker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_AssayNote_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_GelLaneStructure_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_InSituResultImage_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_ISResultStructure_drop.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.GXD_AntibodyMarker DROP CONSTRAINT GXD_AntibodyMarker_pkey CASCADE;
ALTER TABLE mgd.GXD_AntibodyMarker DROP CONSTRAINT GXD_AntibodyMarker__Antibody_key_fkey CASCADE;
ALTER TABLE mgd.GXD_AntibodyMarker DROP CONSTRAINT GXD_AntibodyMarker__Marker_key_fkey CASCADE;
ALTER TABLE mgd.GXD_AntibodyAlias DROP CONSTRAINT GXD_AntibodyMarker__Antibody_key_fkey CASCADE;
ALTER TABLE mgd.GXD_AntibodyPrep DROP CONSTRAINT GXD_AntibodyMarker__Antibody_key_fkey CASCADE;
ALTER TABLE GXD_AntibodyMarker RENAME TO GXD_AntibodyMarker_old;
ALTER TABLE mgd.GXD_AntibodyMarker ADD PRIMARY KEY (_AntibodyMarker_key);
ALTER TABLE mgd.GXD_AntibodyMarker ADD FOREIGN KEY (_Antibody_key) REFERENCES mgd.GXD_Antibody ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_AntibodyMarker ADD FOREIGN KEY (_Marker_key) REFERENCES mgd.MRK_Marker ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_AssayNote DROP CONSTRAINT GXD_AssayNote_pkey CASCADE;
ALTER TABLE mgd.GXD_AssayNote DROP CONSTRAINT GXD_AssayNote__Assay_key_fkey CASCADE;
ALTER TABLE GXD_AssayNote RENAME TO GXD_AssayNote_old;
ALTER TABLE mgd.GXD_AssayNote ADD PRIMARY KEY (_AssayNote_key);
ALTER TABLE mgd.GXD_AssayNote ADD FOREIGN KEY (_Assay_key) REFERENCES mgd.GXD_Assay ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_GelLaneStructure DROP CONSTRAINT GXD_GelLaneStructure_pkey CASCADE;
ALTER TABLE mgd.GXD_GelLaneStructure DROP CONSTRAINT GXD_GelLaneStructure__GelLane_key_fkey CASCADE;
ALTER TABLE mgd.GXD_GelLaneStructure DROP CONSTRAINT GXD_GelLaneStructure__EMAPA_Term_key_fkey CASCADE;
ALTER TABLE mgd.GXD_GelLaneStructure DROP CONSTRAINT GXD_GelLaneStructure__Stage_Term_key_fkey CASCADE;
ALTER TABLE GXD_GelLaneStructure RENAME TO GXD_GelLaneStructure_old;
ALTER TABLE mgd.GXD_GelLaneStructure ADD PRIMARY KEY (_GelLaneStructure_key);
ALTER TABLE mgd.GXD_InSituResultImage DROP CONSTRAINT GXD_InSituResultImage_pkey CASCADE;
ALTER TABLE mgd.GXD_InSituResultImage DROP CONSTRAINT GXD_InSituResultImage__Result_key_fkey CASCADE;
ALTER TABLE mgd.GXD_InSituResultImage DROP CONSTRAINT GXD_InSituResultImage__ImagePane_key_fkey CASCADE;
ALTER TABLE GXD_InSituResultImage RENAME TO GXD_InSituResultImage_old;
ALTER TABLE mgd.GXD_InSituResultImage ADD PRIMARY KEY (_InSituResultImage_key);
ALTER TABLE mgd.GXD_ISResultStructure DROP CONSTRAINT GXD_ISResultStructure_pkey CASCADE;
ALTER TABLE mgd.GXD_ISResultStructure DROP CONSTRAINT GXD_ISResultStructure__Result_key_fkey CASCADE;
ALTER TABLE mgd.GXD_ISResultStructure DROP CONSTRAINT GXD_ISResultStructure__EMAPA_Term_key_fkey CASCADE;
ALTER TABLE mgd.GXD_ISResultStructure DROP CONSTRAINT GXD_ISResultStructure__Stage_Term_key_fkey CASCADE;
ALTER TABLE GXD_ISResultStructure RENAME TO GXD_ISResultStructure_old;
ALTER TABLE mgd.GXD_ISResultStructure ADD PRIMARY KEY (_ISResultStructure_key);

EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/GXD_AntibodyMarker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/GXD_AssayNote_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/GXD_GelLaneStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/GXD_InSituResultImage_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/GXD_ISResultStructure_create.object | tee -a $LOG || exit 1

# autosequence
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_AntibodyMarker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_AssayNote_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_GelLaneStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_InSituResultImage_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_ISResultStructure_create.object | tee -a $LOG || exit 1

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

drop index gxd_assaynote_idx_assay_key;
drop index gxd_gellanestructure_idx_gellane_key;
drop index gxd_insituresultimage_idx_result_key;
drop index gxd_isresultstructure_idx_result_key;

insert into GXD_AntibodyMarker
select nextval('gxd_antibodymarker_seq'), m._Antibody_key, m._Marker_key, m.creation_date, m.modification_date
from GXD_AntibodyMarker_old m
;

insert into GXD_AssayNote
select nextval('gxd_assaynote_seq'), m._Assay_key, m.assayNote, m.creation_date, m.modification_date
from GXD_AssayNote_old m
;

insert into GXD_GelLaneStructure
select nextval('gxd_gellanestructure_seq'), m._GelLane_key, m._EMAPA_Term_key, m._Stage_key, m.creation_date, m.modification_date
from GXD_GelLaneStructure_old m
;

insert into GXD_InSituResultImage
select nextval('gxd_insituresultimage_seq'), m._Result_key, m._ImagePane_key, m.creation_date, m.modification_date
from GXD_InSituResultImage_old m
;

insert into GXD_ISResultStructure
select nextval('gxd_isresultstructure_seq'), m._Result_key, m._EMAPA_Term_key, m._Stage_key, m.creation_date, m.modification_date
from GXD_ISResultStructure_old m
;

ALTER TABLE mgd.GXD_AntibodyMarker ADD PRIMARY KEY (_AntibodyMarker_key);
ALTER TABLE mgd.GXD_AntibodyMarker ADD FOREIGN KEY (_Antibody_key) REFERENCES mgd.GXD_Antibody ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_AntibodyMarker ADD FOREIGN KEY (_Marker_key) REFERENCES mgd.MRK_Marker ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_AssayNote ADD PRIMARY KEY (_AssayNote_key);
ALTER TABLE mgd.GXD_AssayNote ADD FOREIGN KEY (_Assay_key) REFERENCES mgd.GXD_Assay ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_GelLaneStructure ADD PRIMARY KEY (_GelLaneStructure_key);
ALTER TABLE mgd.GXD_InSituResultImage ADD PRIMARY KEY (_InSituResultImage_key);
ALTER TABLE mgd.GXD_ISResultStructure ADD PRIMARY KEY (_ISResultStructure_key);

EOSQL

${PG_MGD_DBSCHEMADIR}/index/GXD_AntibodyMarker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_AssayNote_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_GelLaneStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_InSituResultImage_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_ISResultStructure_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/procedure/MRK_updateKeys_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/GXD_duplicateAssay_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/GXD_addEMAPASet_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/GXD_removeBadGelBand_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/GXD_duplicateAssay_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/GXD_addEMAPASet_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/GXD_duplicateAssay_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/GXD_AntibodyMarker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_Assay_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_AssayNote_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_GelLane_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_GelLaneStructure_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_InSituResult_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_InSituResultImage_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/IMG_ImagePane_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_InSituResult_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_ISResultStructure_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/GXD_Antibody_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_AntibodyMarker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_Assay_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_AssayNote_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_GelLane_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_GelLaneStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_InSituResult_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_InSituResultImage_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/IMG_ImagePane_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_InSituResult_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_ISResultStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/view/GXD_AntibodyMarker_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_GelLaneStructure_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_ISResultImage_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_ISResultImage_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_ISResultStructure_View_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from GXD_AntibodyMarker_old;
select count(*) from GXD_AntibodyMarker;
select count(*) from GXD_AssayNote_old;
select count(*) from GXD_AssayNote;
select count(*) from GXD_GelLaneStructure_old;
select count(*) from GXD_GelLaneStructure;
select count(*) from GXD_InSituResultImage_old;
select count(*) from GXD_InSituResultImage;
select count(*) from GXD_ISResultStructure_old;
select count(*) from GXD_ISResultStructure;

drop table mgd.GXD_AntibodyMarker_old;
drop table mgd.GXD_AssayNote_old;
drop table mgd.GXD_GelLaneStructure_old;
drop table mgd.GXD_InSituResultImage_old;
drop table mgd.GXD_ISResultStructure_old;

EOSQL

date |tee -a $LOG

