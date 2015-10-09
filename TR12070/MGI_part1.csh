#!/bin/csh -fx

#
# Migration for TR12070
#
# mgidbmigration
#
# lib_py_report (trunk)
# ei (tr12070)
# pgmgddbschema (tr12070)
# reports_db (tr12070)
# seqcacheload (tr12070-1)
# assocload (tr12070)
# mgicacheload (tr12070)
# proload (tr12070)
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

#
# PLEASE READ!
# FOR TESTING ONLY 
# MAKE SURE BOTH ARE TURNED OFF FOR REAL MIGRATION
#
#${PG_DBUTILS}/bin/loadDB.csh ${PG_DBSERVER} ${PG_DBNAME} radar /bhmgidevdb01/dump/radar.dump
#${PG_DBUTILS}/bin/loadDB.csh ${PG_DBSERVER} ${PG_DBNAME} mgd /bhmgidevdb01/dump/mgd.dump

#
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
update MGI_dbinfo set schema_version = '6-0-2', public_version = 'MGI 6.02';
EOSQL
date | tee -a ${LOG}

#
# TR12038/DoTS/DFCI/NIA
#
echo 'deleting DoTS/DFCI/NIA data...' | tee -a ${LOG}
/mgi/all/wts_projects/12000/12038/tr12038.csh | tee -a ${LOG} || exit 1

#
# load synonyms
#
echo 'loading MGI-GORel synonyms....' | tee -a ${LOG}
/mgi/all/wts_projects/12000/12070/analysis/tr12070.csh | tee -a ${LOG} || exit 1

#
# Add trigger for VOC_Evidence_Property
#
echo 'Adding trigger for VOC_Evidence_Property' | tee -a ${LOG}
$MGD_DBSCHEMADIR/trigger/VOC_Evidence_Property_drop.object
$MGD_DBSCHEMADIR/trigger/VOC_Evidence_Property_create.object

#
# loading GO annotation extension display link notes
#
echo 'loading GO annotation extension display link notes' | tee -a ${LOG}
${MGICACHELOAD}/go_annot_extensions_display_load.csh | tee -a ${LOG} || exit 1

#
# loading GO isoform display link notes
#
echo 'loading GO Isoform display link notes' | tee -a ${LOG}
${MGICACHELOAD}/go_isoforms_display_load.csh | tee -a ${LOG} || exit 1

#
# proload
#
rm -f $DATALOADSOUTPUT/pro/proload/input/lastrun 
echo 'Loading proload annotations' | tee -a ${LOG}
${PROLOAD}/bin/proload.sh | tee -a ${LOG} || exit 1

#
# sto19/EMAP->EMAPA
#
${DBUTILS}/mgidbmigration/TR12070/sto19.py | tee -a ${LOG} || exit1

#${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

