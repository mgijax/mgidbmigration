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

source ${PUBRPTS}/Configuration
source ${QCRPTS}/Configuration

#
# copy output files from production
#
setenv LINDON1 lindon:/data/reports/reports_db/output
setenv LINDON2 lindon:/data/reports/qcreports_db/output

rcp ${LINDON1}/MGI_Mutations.rpt ${PUBREPORTDIR}/output/MGI_Mutations.rpt.bak
rcp ${LINDON1}/ALL_CellLine_Targeted.rpt ${PUBREPORTDIR}/output/ALL_CellLine_Targeted.rpt.bak
rcp ${LINDON1}/MGI_Knockout_Full.rpt ${PUBREPORTDIR}/output/MGI_Knockout_Full.rpt.bak
rcp ${LINDON1}/MGI_Knockout_NotPublic.rpt ${PUBREPORTDIR}/output/MGI_Knockout_NotPublic.rpt.bak
rcp ${LINDON1}/MGI_Knockout_Public.rpt ${PUBREPORTDIR}/output/MGI_Knockout_Public.rpt.bak

rcp ${LINDON2}/ALL_NoMCL.sql.rpt ${QCREPORTDIR}/output/ALL_NoMCL.sql.rpt.bak
rcp ${LINDON2}/GXD_Transgenic.rpt ${QCREPORTDIR}/output/GXD_Transgenic.rpt.bak
rcp ${LINDON2}/ALL_MolNotesNoMP.rpt ${QCREPORTDIR}/output/ALL_MolNotesNoMP.rpt.bak
rcp ${LINDON2}/ALL_Progress.current.rpt ${QCREPORTDIR}/output/ALL_Progress.current.rpt.bak

rm -rf ${PUBREPORTDIR}/output/*.diff
rm -rf ${QCREPORTDIR}/output/*.diff

#
# public reports
#

cd ${PUBRPTS}/weekly_postgres
./MGI_Mutations.py

cd ${PUBRPTS}/weekly_sybase
./ALL_CellLine_Targeted.py
./MGI_Knockout.py

#
# qc reports
#

cd ${QCRPTS}/mgd

foreach i (ALL_NoMCL.sql)
reportisql.csh $i ${QCOUTPUTDIR}/$i.rpt ${MGD_DBSERVER} ${MGD_DBNAME}
end

cd ${QCRPTS}/monthly
./GXD_Transgenic.py

cd ${QCRPTS}/weekly
./ALL_MolNotesNoMP.py

mv -f $QCOUTPUTDIR/`basename $i py`[0-9]*.rpt $QCALLELEARCHIVE
rm -rf $QCOUTPUTDIR/`basename $i py`current.rpt
./ALL_Progress.py
ln -s $QCOUTPUTDIR/`basename $i py`${DATE}.rpt $QCOUTPUTDIR/`basename $i py`current.rpt

#
# diffs
#

cd ${PUBREPORTDIR}/output
foreach i (MGI_Mutations.rpt ALL_CellLine_Targeted.rpt MGI_Knockout*.rpt)
wc -l ${PUBREPORTDIR}/output/${i}.bak 
wc -l ${PUBREPORTDIR}/output/${i}
end

cd ${QCREPORTDIR}/output
foreach i (ALL_NoMCL.sql.rpt GXD_Transgenic.rpt ALL_MolNotesNoMP.rpt ALL_Progress.current.rpt)
wc -l ${QCREPORTDIR}/output/${i}.bak 
wc -l ${QCREPORTDIR}/output/${i}
end

date | tee -a ${LOG}

echo "--- Finished" | tee -a ${LOG}

