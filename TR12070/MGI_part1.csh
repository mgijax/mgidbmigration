#!/bin/csh -fx

#
# Migration for TR12070
#
# mgidbmigration
#
# lib_py_report (trunk)
# ei
# pgmgddbschema
# reports_db
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
# only for testing until a new production load is done
#
/mgi/all/wts_projects/12000/12070/tr12070.csh | tee -a ${LOG}

#
# TR12038/DoTS/DFCI/NIA
#
echo 'deleting DoTS/DFCI/NIA data...' | tee -a ${LOG}
/mgi/all/wts_projects/12000/12038/tr12038.csh | tee -a ${LOG}

#
# load synonyms
#
echo 'loading MGI-GORel synonyms....' | tee -a ${LOG}
/mgi/all/wts_projects/12000/12070/analysis/tr12070.csh | tee -a ${LOG}

#
# loading GO annotation extension display link notes
#
echo 'loading GO annotation extension display link notes' | tee -a ${LOG}
${MGICACHELOAD}/go_annot_extensions_display_load.csh | tee -a ${LOG}

#
# proload
#
echo 'Loading proload annotations" | tee -a ${LOG}
${PROLOAD}/bin/proload.sh | tee -a ${LOG}

#${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

