#!/bin/csh -fx

#
# Migration for TR12223
#
# new input files to copy from production:
# scp bhmgiapp01:/data/loads/mgi/emapload/input/EMAPA.obo /data/loads/mgi/vocload/emap/input
#
# on production (bhmgiapp01)
# rm -rf /data/loads/mgi/emapload
# make sure Terry uses bhmgiapp01, not hobbiton!
#
# loadadmin/prod/dailytasks.csh:${EMAPLOAD}/bin/emapload.sh
# change to:
# loadadmin/prod/dailytasks.csh:${VOCLOAD}/emap/emapload.sh
#
# is-obsolete:
# adsystemload
# toposortload
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

#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec radar /bhmgidevdb01/dump/radar.dump
#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec mgd /bhmgidevdb01/dump/mgd.dump

#
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
update MGI_dbinfo set schema_version = '6-0-4', public_version = 'MGI 6.04';
EOSQL
date | tee -a ${LOG}

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
ALTER TABLE MGI_SetMember RENAME TO MGI_SetMember_old;

ALTER TABLE GXD_TheilerStage DROP COLUMN IF EXISTS _defaultSystem_key;
ALTER TABLE mgd.GXD_Structure DROP CONSTRAINT GXD_Structure__Stage_key_fkey CASCADE;
ALTER TABLE mgd.GXD_TheilerStage DROP CONSTRAINT GXD_TheilerStage_pkey CASCADE;

ALTER TABLE VOC_Term_EMAPA ALTER startStage TYPE integer USING startStage::integer;
ALTER TABLE VOC_Term_EMAPA ALTER endStage TYPE integer USING endStage::integer;
ALTER TABLE VOC_Term_EMAPS RENAME COLUMN stage to _Stage_key;
ALTER TABLE VOC_Term_EMAPS ALTER _Stage_key TYPE integer USING _Stage_key::integer;

ALTER TABLE mgd.VOC_Annot ADD FOREIGN KEY (_Qualifier_key) REFERENCES mgd.VOC_Term DEFERRABLE;

DROP VIEW IF EXISTS mgd.GXD_Structure_Acc_View;

DROP TRIGGER IF EXISTS GXD_Structure_delete_trigger ON GXD_Structure;
DROP FUNCTION IF EXISTS GXD_Structure_delete();
DROP TRIGGER IF EXISTS GXD_Structure_insert_trigger ON GXD_Structure;
DROP FUNCTION IF EXISTS GXD_Structure_insert();
DROP TRIGGER IF EXISTS GXD_StructureName_insert_trigger ON GXD_StructureName;
DROP FUNCTION IF EXISTS GXD_StructureName_insert();
DROP TRIGGER IF EXISTS GXD_StructureName_update_trigger ON GXD_StructureName;
DROP FUNCTION IF EXISTS GXD_StructureName_update();
DROP FUNCTION IF EXISTS GXD_removeBadGelBand(int);
DROP FUNCTION IF EXISTS MGI_resetSequenceNum(varchar,int);
DROP FUNCTION IF EXISTS MRK_insertHistory(int,int,int,int,int,int,varchar,timestamp,int,int,timestamp,timestamp);
DROP FUNCTION IF EXISTS MGI_resetAgeMinMax(varchar,int);
DROP TRIGGER IF EXISTS IMG_ImagePane_Assoc_delete_trigger ON IMG_ImagePane_Assoc;
DROP FUNCTION IF EXISTS IMG_ImagePane_Assoc_delete();
DROP TRIGGER IF EXISTS ALL_CellLine_insert_trigger ON ALL_CellLine;
DROP FUNCTION IF EXISTS ALL_CellLine_insert();

DROP VIEW IF EXISTS mgd.MGI_Organism_Homology_View;
DROP VIEW IF EXISTS mgd.MAP_Feature_View;
DROP VIEW IF EXISTS mgd.MRK_Types_Summary_View;
DROP VIEW IF EXISTS mgd.ALL_Allele_Strain_View;
DROP VIEW IF EXISTS mgd.ALL_CellLine_Strain_View;
DROP VIEW IF EXISTS mgd.BIB_Summary_View;
DROP VIEW IF EXISTS mgd.GXD_Antibody_Summary_View;
DROP VIEW IF EXISTS mgd.GXD_Assay_Summary_View;
DROP VIEW IF EXISTS mgd.PRB_Summary_View;
DROP VIEW IF EXISTS mgd.VOC_InterPro_Summary_View;
DROP VIEW IF EXISTS mgd.VOC_Term_Gender_View;
DROP VIEW IF EXISTS mgd.VOC_Term_SegmentType_View;
DROP VIEW IF EXISTS mgd.VOC_Vocab_DAG_Summary_View;
DROP VIEW IF EXISTS mgd.VOC_Vocab_Summary_View;
DROP VIEW IF EXISTS mgd.MGI_Organism_Antibody_View;
DROP VIEW IF EXISTS mgd.MGI_Synonym_HumMarker_View;
DROP VIEW IF EXISTS mgd.MGI_TranslationType_View;

UPDATE MGI_StatisticSql 
SET sqlchunk = 
'select count(*) from (select distinct _EMAPA_Term_key, _Stage_key from All_Cre_Cache) as s' WHERE _statistic_key = 90
;

DELETE FROM MGI_Reference_Assoc where _MGIType_key = 29; 
DELETE FROM MGI_RefAssocType where _MGIType_key = 29; 
DELETE FROM ACC_MGIType where _MGIType_key in (14,26,29,37);

-- remove mgi ids added to es cell lines when postgres migration was done
DELETE FROM ACC_Accession where _MGIType_key = 28 and _logicaldb_key = 1;

EOSQL
${PG_MGD_DBSCHEMADIR}/view/GXD_GelLaneStructure_View_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_ISResultStructure_View_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_Genotype_View_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/MGI_Statistic_View_drop.object | tee -a $LOG || exit 1
date | tee -a ${LOG}

echo 'step 2 : create new tables' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/table/ALL_Cre_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/GXD_Expression_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/GXD_GelLaneStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/GXD_ISResultStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/MGI_SetMember_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/MGI_SetMember_EMAPA_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/MRK_OMIM_Cache_create.object | tee -a $LOG || exit 1

echo 'step 3 : run ad-to-emapa migration' | tee -a $LOG
./adToemapa.csh | tee -a $LOG || exit 1

echo 'step 4 : run cre (mgi_setmember) migration' | tee -a $LOG
./cre.csh | tee -a $LOG || exit 1

echo 'step 5 : create foreign keys for new tables' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/ALL_Cre_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_Expression_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_GelLaneStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_ISResultStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_SetMember_EMAPA_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_SetMember_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_SetMember_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_OMIM_Cache_create.object | tee -a $LOG || exit 1

echo 'step 6 : create more foreign keys for new tables' | tee -a $LOG
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
ALTER TABLE mgd.MGI_SetMember ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.MGI_SetMember ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;

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

-- remove old Anatomical System vocabulary (CRE)
DELETE FROM VOC_Term where _vocab_key = 75;
DELETE FROM VOC_Vocab where _vocab_key = 75;

insert into MGI_Set values(1046, 13, 'EMAPA/Stage', 1, 1001, 1001, now(), now());

EOSQL
date | tee -a ${LOG}

echo 'step 7 : create indexes on new tables' | tee -a $LOG
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

echo 'step 8 : add comments/views/procedure' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/comments/ALL_Cre_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/GXD_Expression_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/GXD_GelLaneStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/GXD_ISResultStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/MGI_SetMember_EMAPA_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/MGI_SetMember_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/MRK_OMIM_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_GelLaneStructure_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_ISResultStructure_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_Genotype_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/MGI_Statistic_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/ALL_Allele_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Annot_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Term_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/MGI_SetMember_EMAPA_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/MGI_Statistic_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/procedure_drop.sh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/procedure_create.sh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

date | tee -a ${LOG}

echo 'step 9 : run setload/setload.csh cre.config' | tee -a $LOG
${SETLOAD}/setload.csh cre.config | tee -a $LOG || exit 1
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select a.accID, t.term, s.* 
from MGI_SetMember s, VOC_Term t, ACC_Accession a
where s._Set_key = 1047
and s._Object_key = t._Term_key
and t._Term_key = a._Object_key
and a._MGIType_key = 13
;
EOSQL

echo 'step 10 : run vocload/emap/emapload.sh' | tee -a $LOG
${VOCLOAD}/emap/emapload.sh | tee -a $LOG || exit 1

echo 'step 11 : run mgicacheload/gxdexpression.csh' | tee -a $LOG
${MGICACHELOAD}/gxdexpression.csh | tee -a $LOG || exit 1

echo 'step 12 : run mrkcacheload/mrkomim.csh' | tee -a $LOG
${MRKCACHELOAD}/mrkomim.csh | tee -a $LOG || exit 1

echo 'step 13 : run allcacheload/allelecrecache.csh' | tee -a $LOG
${ALLCACHELOAD}/allelecrecache.csh | tee -a $LOG || exit 1

echo 'step 14 : run statistics' | tee -a $LOG
rm -rf ${MGI_PYTHONLIB}/stats* | tee -a $LOG
${PG_DBUTILS}/bin/measurements/addMeasurements.csh | tee -a $LOG || exit 1

echo 'step 15 : orphan clean-up' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/test/cleanobjects.sh | tee -a $LOG || exit 1

echo 'step 16 : run pwi.csh' | tee -a $LOG
./pwi.csh | tee -a $LOG || exit 1

echo 'step 17 : permissions' | tee -a $LOG
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1

echo 'step 18 : reports' | tee -a $LOG
./qcnightly_reports.csh | tee -a $LOG || exit 1

#echo 'step 18 : public' | tee -a $LOG
#${PG_DBUTILS}/sp/MGI_deletePrivateData.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

