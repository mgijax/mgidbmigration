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

#
# run some qc/public reports using existing reports and existing database
# we don't need to do this for the release-testing
#

source ${PUBRPTS}/Configuration

cd ${PUBRPTS}/weekly_postgres
./MGI_Mutations.py

cd ${PUBRPTS}/weekly_sybase
./ALL_CellLine_Targeted.py
./MGI_Knockout.py

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

