#!/bin/csh -fx

#
# Migration for TR12223
#
# schema change
# schema migration
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec mgd /bhmgidevdb01/dump/mgd.postsunday.dump

#
# update schema-version and public-version
#
#date | tee -a ${LOG}
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#update MGI_dbinfo set schema_version = '6-0-?', public_version = 'MGI 6.0?';
#EOSQL
#date | tee -a ${LOG}

echo 'step 1 : drop/alter tables/views/etc.' | tee -a $LOG
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1

DROP TABLE ALL_Cre_Cache;
DROP TABLE GXD_Expression;
DROP TABLE GXD_StructureClosure;
DROP TABLE MRK_OMIM_Cache;

ALTER TABLE mgd.GXD_GelLaneStructure DROP CONSTRAINT GXD_GelLaneStructure__GelLane_key_fkey CASCADE;
ALTER TABLE mgd.GXD_GelLaneStructure DROP CONSTRAINT GXD_GelLaneStructure_pkey CASCADE;
ALTER TABLE mgd.GXD_ISResultStructure DROP CONSTRAINT GXD_ISResultStructure__Result_key_fkey CASCADE;
ALTER TABLE mgd.GXD_ISResultStructure DROP CONSTRAINT GXD_ISResultStructure_pkey CASCADE;

ALTER TABLE GXD_GelLaneStructure RENAME TO GXD_GelLaneStructure_old;
ALTER TABLE GXD_ISResultStructure RENAME TO GXD_ISResultStructure_old;

ALTER TABLE GXD_TheilerStage DROP COLUMN IF EXISTS _defaultSystem_key;
ALTER TABLE mgd.GXD_Structure DROP CONSTRAINT GXD_Structure__Stage_key_fkey CASCADE;
ALTER TABLE mgd.GXD_TheilerStage DROP CONSTRAINT GXD_TheilerStage_pkey CASCADE;

ALTER TABLE VOC_Term_EMAPA ALTER startStage TYPE integer USING startStage::integer;
ALTER TABLE VOC_Term_EMAPA ALTER endStage TYPE integer USING endStage::integer;
ALTER TABLE VOC_Term_EMAPS RENAME COLUMN stage to _Stage_key;
ALTER TABLE VOC_Term_EMAPS ALTER _Stage_key TYPE integer USING _Stage_key::integer;

DROP VIEW IF EXISTS mgd.GXD_Structure_Acc_View;

DROP TRIGGER IF EXISTS GXD_Structure_delete_trigger ON GXD_Structure;
DROP FUNCTION IF EXISTS GXD_Structure_delete();
DROP TRIGGER IF EXISTS GXD_Structure_insert_trigger ON GXD_Structure;
DROP FUNCTION IF EXISTS GXD_Structure_insert();
DROP TRIGGER IF EXISTS GXD_StructureName_insert_trigger ON GXD_StructureName;
DROP FUNCTION IF EXISTS GXD_StructureName_insert();
DROP TRIGGER IF EXISTS GXD_StructureName_update_trigger ON GXD_StructureName;
DROP FUNCTION IF EXISTS GXD_StructureName_update();

UPDATE MGI_StatisticSql 
SET sqlchunk = 'select count(*) from (select distinct _EMAPA_Term_key, _Stage_key from All_Cre_Cache) as s'
WHERE _statistic_key = 90
;

EOSQL
${PG_MGD_DBSCHEMADIR}/view/GXD_GelLaneStructure_View_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_ISResultStructure_View_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_Genotype_View_drop.object | tee -a $LOG || exit 1
date | tee -a ${LOG}

echo 'step 2 : create new tables' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/table/ALL_Cre_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/GXD_Expression_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/GXD_GelLaneStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/GXD_ISResultStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/MGI_SetMember_EMAPA_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/MRK_OMIM_Cache_create.object | tee -a $LOG || exit 1

echo 'step 3 : run migration (NOT YET)' | tee -a $LOG
./adToemapa.csh | tee -a $LOG || exit 1

echo 'step 4 : create foreign keys for new tables' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/ALL_Cre_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_Expression_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_GelLaneStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_ISResultStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_SetMember_EMAPA_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_SetMember_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_SetMember_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_OMIM_Cache_create.object | tee -a $LOG || exit 1

echo 'step 5 : create more foreign keys for new tables' | tee -a $LOG
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1

ALTER TABLE mgd.ALL_Cre_Cache ADD FOREIGN KEY (_Allele_key) REFERENCES mgd.ALL_Allele ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.ALL_Cre_Cache ADD FOREIGN KEY (_Assay_key) REFERENCES mgd.GXD_Assay ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.ALL_Cre_Cache ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.ALL_Cre_Cache ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.ALL_Cre_Cache ADD FOREIGN KEY (_Allele_Type_key) REFERENCES mgd.VOC_Term ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.ALL_Cre_Cache ADD FOREIGN KEY (_EMAPA_Term_key) REFERENCES mgd.VOC_Term ON DELETE CASCADE DEFERRABLE;

ALTER TABLE mgd.GXD_Expression ADD FOREIGN KEY (_Refs_key) REFERENCES mgd.BIB_Refs ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_Expression ADD FOREIGN KEY (_Assay_key) REFERENCES mgd.GXD_Assay ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_Expression ADD FOREIGN KEY (_AssayType_key) REFERENCES mgd.GXD_AssayType DEFERRABLE;
ALTER TABLE mgd.GXD_Expression ADD FOREIGN KEY (_GelLane_key) REFERENCES mgd.GXD_GelLane ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_Expression ADD FOREIGN KEY (_Genotype_key) REFERENCES mgd.GXD_Genotype DEFERRABLE;
ALTER TABLE mgd.GXD_Expression ADD FOREIGN KEY (_Specimen_key) REFERENCES mgd.GXD_Specimen ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_Expression ADD FOREIGN KEY (_Marker_key) REFERENCES mgd.MRK_Marker DEFERRABLE;
ALTER TABLE mgd.GXD_Expression ADD FOREIGN KEY (_EMAPA_Term_key) REFERENCES mgd.VOC_Term ON DELETE CASCADE DEFERRABLE;

ALTER TABLE mgd.GXD_GelLaneStructure ADD FOREIGN KEY (_EMAPA_Term_key) REFERENCES mgd.VOC_Term DEFERRABLE;
ALTER TABLE mgd.GXD_GelLaneStructure ADD FOREIGN KEY (_GelLane_key) REFERENCES mgd.GXD_GelLane ON DELETE CASCADE DEFERRABLE;

ALTER TABLE mgd.GXD_ISResultStructure ADD FOREIGN KEY (_Result_key) REFERENCES mgd.GXD_InSituResult ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_ISResultStructure ADD PRIMARY KEY (_Result_key, _EMAPA_Term_key, _Stage_key);
ALTER TABLE mgd.GXD_ISResultStructure ADD FOREIGN KEY (_EMAPA_Term_key) REFERENCES mgd.VOC_Term DEFERRABLE;

ALTER TABLE mgd.MGI_SetMember_EMAPA ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.MGI_SetMember_EMAPA ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;

ALTER TABLE mgd.MRK_OMIM_Cache ADD FOREIGN KEY (_Allele_key) REFERENCES mgd.ALL_Allele ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.MRK_OMIM_Cache ADD FOREIGN KEY (_Refs_key) REFERENCES mgd.BIB_Refs ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.MRK_OMIM_Cache ADD FOREIGN KEY (_Genotype_key) REFERENCES mgd.GXD_Genotype ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.MRK_OMIM_Cache ADD FOREIGN KEY (_Organism_key) REFERENCES mgd.MGI_Organism DEFERRABLE;
ALTER TABLE mgd.MRK_OMIM_Cache ADD FOREIGN KEY (_OrthologOrganism_key) REFERENCES mgd.MGI_Organism DEFERRABLE;
ALTER TABLE mgd.MRK_OMIM_Cache ADD FOREIGN KEY (_Marker_key) REFERENCES mgd.MRK_Marker ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.MRK_OMIM_Cache ADD FOREIGN KEY (_OrthologMarker_key) REFERENCES mgd.MRK_Marker ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.MRK_OMIM_Cache ADD FOREIGN KEY (_Marker_Type_key) REFERENCES mgd.MRK_Types DEFERRABLE;
ALTER TABLE mgd.MRK_OMIM_Cache ADD FOREIGN KEY (_Term_key) REFERENCES mgd.VOC_Term ON DELETE CASCADE DEFERRABLE;

DELETE FROM ACC_Accession where _MGIType_key = 38;
DELETE FROM ACC_MGIType where _MGIType_key = 38;
DELETE FROM MGI_NoteType where _notetype_key = 1006;

insert into MGI_Set values(1046, 13, 'EMAPA/Stage', 1, 1001, 1001, now(), now());

EOSQL
date | tee -a ${LOG}

echo 'step 6 : create indexes on new tables' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/ALL_Cre_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_Expression_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_GelLaneStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_ISResultStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/VOC_Marker_Cache_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/VOC_Marker_Cache_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/VOC_Term_EMAPA_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/VOC_Term_EMAPA_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/VOC_Term_EMAPS_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/VOC_Term_EMAPS_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/MGI_SetMember_EMAPA_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/MGI_SetMember_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/MGI_SetMember_create.object | tee -a $LOG
#${PG_MGD_DBSCHEMADIR}/index/GXD_TheilerStage_drop.object | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/index/GXD_TheilerStage_create.object | tee -a $LOG || exit 1

echo 'step 7 : add comments/views/procedure' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/comments/ALL_Cre_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/GXD_Expression_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/GXD_GelLaneStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/GXD_ISResultStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/MGI_SetMember_EMAPA_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/MRK_OMIM_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_GelLaneStructure_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_ISResultStructure_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_Genotype_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/GXD_duplicateAssay_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/GXD_addEMAPASet_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/ALL_Allele_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Term_create.object | tee -a $LOG || exit 1

date | tee -a ${LOG}

echo 'step 8 : run mgicacheload/gxdexpression.csh' | tee -a $LOG
${MGICACHELOAD}/gxdexpression.csh | tee -a $LOG || exit 1

echo 'step 9 : run mrkcacheload/mrkomim.csh' | tee -a $LOG
${MRKCACHELOAD}/mrkomim.csh | tee -a $LOG || exit 1

echo 'step 9 : run allcacheload/allelecrecache.csh' | tee -a $LOG
${ALLCACHELOAD}/allelecrecache.csh | tee -a $LOG || exit 1

echo 'step 10 : run statistics' | tee -a $LOG
${PG_DBUTILS}/bin/measurements/addMeasurements.csh | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

