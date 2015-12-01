#!/bin/csh -fx

#
# Migration for TR12070
#
# verify the most recent copies of these files exist:
# /data/downloads/goa/gene_association.goa_mouse.gz
# /data/downloads/purl.obolibrary.org/obo/uberon.obo
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

#echo "Ensure new note types exist"
#./scrumdog_testdata.sh

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
# sto19/EMAP->EMAPA
#
echo 'loading sto19/EMAP-EMAPA migration' | tee -a ${LOG}
${DBUTILS}/mgidbmigration/TR12070/sto19.py | tee -a ${LOG} || exit1

#
# sto20/MA-EMAPA-TS
#
echo 'loading sto20/MA->EMAPS migration' | tee -a ${LOG}
${DBUTILS}/mgidbmigration/TR12070/sto20.py | tee -a ${LOG} || exit1

#
# sto18/goaload/Uberon
#
echo 'running GOA-Mouse (goaload) translation Uberon Ids to EMAPA' | tee -a ${LOG}
${GOALOAD}/bin/goa.csh | tee -a ${LOG} || exit 1
echo 'running GO-GAF file' | tee -a ${LOG}
cd ${PUBRPTS}
source ./Configuration
cd ${PUBRPTS}/daily
./GO_gene_association.py | tee -a ${LOG}

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
# sto80/genemodelload stuff
echo 'loading sto80/genemodelload stuff' | tee -a ${LOG}
${DBUTILS}/mgidbmigration/TR12070/sto80.csh | tee -a ${LOG} || exit1

${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

