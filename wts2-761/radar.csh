#!/bin/csh -f

#
# remove obsolete tables
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
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

ALTER TABLE radar.QC_MS_InvalidGender DROP CONSTRAINT QC_MS_InvalidGender__JobStream_key_fkey CASCADE;
ALTER TABLE radar.QC_MS_InvalidCellLine DROP CONSTRAINT QC_MS_InvalidCellLine__JobStream_key_fkey CASCADE;
ALTER TABLE radar.QC_MS_InvalidTissue DROP CONSTRAINT QC_MS_InvalidTissue__JobStream_key_fkey CASCADE;
ALTER TABLE radar.QC_MS_InvalidStrain DROP CONSTRAINT QC_MS_InvalidStrain__JobStream_key_fkey CASCADE;
ALTER TABLE radar.QC_MS_InvalidLibrary DROP CONSTRAINT QC_MS_InvalidLibrary__JobStream_key_fkey CASCADE;

drop table QC_MS_InvalidCellLine;
drop table QC_MS_InvalidGender;
drop table QC_MS_InvalidLibrary;   
drop table QC_MS_InvalidStrain;  
drop table QC_MS_InvalidTissue;

EOSQL

${PG_RADAR_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG

${MGI_JAVALIB}/lib_java_core/Install | tee -a $LOG
${MGI_JAVALIB}/lib_java_dbsmgd/Install | tee -a $LOG
${MGI_JAVALIB}/lib_java_dbsrdr/Install | tee -a $LOG
${MGI_JAVALIB}/lib_java_dla/Install | tee -a $LOG

#
# to test the radar still works correctly
# do not run on production
#
#${MIRROR_WGET}/download_package purl.obolibrary.org.pr | tee -a $LOG
#${MIRROR_WGET}/download_package purl.obolibrary.org.uberon.obo | tee -a $LOG
#${MIRROR_WGET}/download_package snapshot.geneontology.org.goload.noctua | tee -a $LOG
#${GOLOAD}/godaily.sh | tee -a $LOG

date |tee -a $LOG

