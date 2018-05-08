#!/bin/csh -fx

#
# TR12734/Genome FeVah
#
# (part 1 running schema changes)
#
# tr12734 branch:
# pgmgddbschema
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
EOSQL

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
#date | tee -a ${LOG}
#echo 'data cleanup' | tee -a $LOG
#${PG_MGD_DBSCHEMADIR}/test/cleanobjects.sh | tee -a $LOG || exit 1

#
# rebuild the java dla, if needed due to schema changes
# this can be commented out if not necessary
#
${MGI_JAVALIB}/lib_java_dbsmgd/Install | tee -a $LOG
${MGI_JAVALIB}/lib_java_dla/Install | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished part 1' | tee -a ${LOG}

