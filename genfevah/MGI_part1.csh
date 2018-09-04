#!/bin/csh -fx

#
# TR12734/Genome FeVah
#
# (part 1 running schema changes)
#
# tr12734 branch:
#
# lib_py_postgres : merge
# lib_java_dbsmgd : merge
# lib_java_dla : merge
#
# ei : merge
# pgdbutilities : merge
# pgmgddbschema : merge
#
# mrkcacheload : merge
# seqcacheload : merge
#
# assemblyseqload : merge
# assocload : merge
# genemodelload : merge
# goload : merge
# seqseqassocload : merge
# vega_ensemblseqload : merge
# vocload : merge
#
# qcreports_db : merge
# reports_db : merge
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
echo '--- starting part 1' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec radar /bhmgidevdb01/dump/radar.dump
#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec mgd /bhmgidevdb01/dump/mgd.dump
#${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

#
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
update MGI_dbinfo set schema_version = '6-0-13', public_version = 'MGI 6.013';
EOSQL

rm -rf ${LIBDIRS}/stats_pg.* | tee -a ${LOG}

date | tee -a ${LOG}

#
# MRK_StrainMarker
#
date | tee -a ${LOG}
echo 'createing MRK_StrainMarker' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/table/MRK_StrainMarker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_StrainMarker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/MRK_StrainMarker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/MRK_StrainMarker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/MRK_StrainMarker_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.MRK_StrainMarker ADD FOREIGN KEY (_Strain_key) REFERENCES mgd.PRB_Strain DEFERRABLE;
ALTER TABLE mgd.MRK_StrainMarker ADD FOREIGN KEY (_Marker_key) REFERENCES mgd.MRK_Marker DEFERRABLE;
ALTER TABLE mgd.MRK_StrainMarker ADD FOREIGN KEY (_Refs_key) REFERENCES mgd.BIB_Refs DEFERRABLE;
ALTER TABLE mgd.MRK_StrainMarker ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.MRK_StrainMarker ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;

DROP FUNCTION IF EXISTS MGI_recordMeasurement(text,int,numeric);
drop view MGI_Statistic_View;
drop table MGI_StatisticSql;
drop table MGI_Measurement;
drop table MGI_Statistic;
delete from MGI_Set where _Set_key in (1024, 1025, 1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034,
1035, 1036, 1037, 1038, 1039, 1040, 1044, 1045);
delete from MGI_SetMember where _Set_key in (1024, 1025, 1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034,
1035, 1036, 1037, 1038, 1039, 1040, 1044, 1045);
delete from MGI_Set where _MGIType_key = 34;
delete from ACC_MGIType where _MGIType_key = 34;

EOSQL

#
# MRK_Location_Cache
# drop/rebuild/removing _Cache_key
#
${PG_MGD_DBSCHEMADIR}/table/MRK_Location_Cache_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/MRK_Location_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/MRK_Location_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Location_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MRK_reloadLocation_create.object | tee -a $LOG || exit 1
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.MRK_Location_Cache ADD FOREIGN KEY (_Organism_key) REFERENCES mgd.MGI_Organism DEFERRABLE;
ALTER TABLE mgd.MRK_Location_Cache ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.MRK_Location_Cache ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.MRK_Location_Cache ADD FOREIGN KEY (_Marker_key) REFERENCES mgd.MRK_Marker ON DELETE CASCADE DEFERRABLE;
EOSQL

#
# MRK_BiotypeMarker
# drop/rebuild/adding primaryFeatureType
#
${PG_MGD_DBSCHEMADIR}/table/MRK_BiotypeMapping_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/MRK_BiotypeMapping_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/MRK_BiotypeMapping_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_BiotypeMapping_create.object | tee -a $LOG || exit 1
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.MRK_BiotypeMapping ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.MRK_BiotypeMapping ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.MRK_BiotypeMapping ADD FOREIGN KEY (_biotypeterm_key) REFERENCES mgd.VOC_Term DEFERRABLE;
ALTER TABLE mgd.MRK_BiotypeMapping ADD FOREIGN KEY (_MCVTerm_key) REFERENCES mgd.VOC_Term DEFERRABLE;
ALTER TABLE mgd.MRK_BiotypeMapping ADD FOREIGN KEY (_PrimaryMCVTerm_key) REFERENCES mgd.VOC_Term DEFERRABLE;
ALTER TABLE mgd.MRK_BiotypeMapping ADD FOREIGN KEY (_Marker_Type_key) REFERENCES mgd.MRK_Types DEFERRABLE;
ALTER TABLE mgd.MRK_BiotypeMapping ADD FOREIGN KEY (_biotypevocab_key) REFERENCES mgd.VOC_Vocab DEFERRABLE;
EOSQL

# in preparation for TR11855...
#insert into voc_term values((select max(_Term_key) + 1 from VOC_Term), 56, 'Needs Review - Chr', 'Needs Review - Chr',null,4,0,1001,1001,now(),now())
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
DROP FUNCTION IF EXISTS PRB_setStrainReview(int,int);
EOSQL
${PG_MGD_DBSCHEMADIR}/procedure/PRB_setStrainReview_create.object | tee -a $LOG || exit 1

#
# reconfig.sh:
# Drop and re-create database triggers, stored procedures, views and comments
# always a good idea to do to make sure that nothing was missed with schema changes
#
date | tee -a ${LOG}
echo 'step ??: running triggers, procedures, views, comments' | tee -a $LOG
#${PG_MGD_DBSCHEMADIR}/reconfig.csh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/MRK_AccRef2_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/comments.sh | tee -a $LOG || exit 1
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1
#${PG_DBUTILS}/bin/vacuumDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
#${PG_DBUTILS}/bin/analyzeDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1

#
# cleanobjects.sh : removing stray mgi_notes
#
date | tee -a ${LOG}
echo 'data cleanup' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/test/cleanobjects.sh | tee -a $LOG || exit 1

#
# rebuild the java dla, if needed due to schema changes
# this can be commented out if not necessary
#
${MGI_JAVALIB}/lib_java_dbsmgd/Install | tee -a $LOG
${MGI_JAVALIB}/lib_java_dla/Install | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished part 1' | tee -a ${LOG}

