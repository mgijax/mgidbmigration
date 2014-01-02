#!/bin/csh -fx

#
# run reports for migration
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
# run some qc/public reports using existing reports and existing database
# we don't need to do this for the release-testing
#

setenv PUBRPTS ${MGI_LIVE}/reports_db-tr11515-BP
source ${PUBRPTS}/Configuration

cd ${PUBRPTS}/weekly_postgres
./MGI_Mutations.py

cd ${PUBRPTS}/weekly_sybase
./ALL_CellLine_Targeted.py
./MGI_Knockout.py

cp ${PUBREPORTDIR}/output/MGI_Mutations.html ${PUBREPORTDIR}/output/MGI_Mutations.html.before
cp ${PUBREPORTDIR}/output/MGI_Mutations.rpt ${PUBREPORTDIR}/output/MGI_Mutations.rpt.before
cp ${PUBREPORTDIR}/output/ALL_CellLine_Targeted.rpt ${PUBREPORTDIR}/output/ALL_CellLine_Targeted.rpt.before
cp ${PUBREPORTDIR}/output/MGI_Knockout_Full.rpt ${PUBREPORTDIR}/output/MGI_Knockout_Full.rpt.before
cp ${PUBREPORTDIR}/output/MGI_Knockout_Full.html ${PUBREPORTDIR}/output/MGI_Knockout_Full.html.before
cp ${PUBREPORTDIR}/output/MGI_Knockout_NotPublic.rpt ${PUBREPORTDIR}/output/MGI_Knockout_NotPublic.rpt.before
cp ${PUBREPORTDIR}/output/MGI_Knockout_Public.rpt ${PUBREPORTDIR}/output/MGI_Knockout_Public.rpt.before

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

