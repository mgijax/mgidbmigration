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
# public reports
#

source ${PUBRPTS}/Configuration

cd ${PUBRPTS}/weekly_postgres
./MGI_Mutations.py

cd ${PUBRPTS}/weekly_sybase
./ALL_CellLine_Targeted.py
./MGI_Knockout.py

#
# qc reports
#

source ${QCRPTS}/Configuration

cd ${QCRPTS}/mgd

foreach i (ALL_NoMCL.sql)
reportisql.csh $i ${QCOUTPUTDIR}/$i.rpt ${MGD_DBSERVER} ${MGD_DBNAME}
end

cd ${QCRPTS}/monthly
./GXD_Transgenic.py

cd ${QCRPTS}/weekly
./ALL_MolNotesNoMP.py
./ALL_Progress.py

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

