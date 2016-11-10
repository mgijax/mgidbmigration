#!/bin/csh -f

#
# qcnightly_reports.csh
#
# Script to generate nightly QC reports.
#
# Usage: qcnightly_reports.csh
#

cd `dirname $0` && source ${QCRPTS}/Configuration

setenv LOG `basename $0`.log
rm -rf ${LOG}
touch ${LOG}

echo `date`: Start nightly QC reports | tee -a ${LOG}

cd ${QCMGD}

foreach i (MRK_GOUnknown.sql MRK_Reserved.sql)
    echo `date`: $i | tee -a ${LOG}
    ${QCRPTS}/reports.csh $i ${QCOUTPUTDIR}/$i.rpt ${MGD_DBSERVER} ${MGD_DBNAME}
end

foreach i (GO_Combined_Report.py MRK_GOIEA.py MRK_QTL.py HMD_SymbolDiffs.py)
    echo `date`: $i | tee -a ${LOG}
    $i | tee -a ${LOG}
end

cd ${QCWEEKLY}

foreach i (VOC_OMIMObsolete.sql)
    echo `date`: $i | tee -a ${LOG}
    ${QCRPTS}/reports.csh $i ${QCOUTPUTDIR}/$i.rpt ${MGD_DBSERVER} ${MGD_DBNAME}
end

foreach i (ALL_OMIMNoMP.py ALL_Progress.py)
    echo `date`: $i | tee -a ${LOG}
    $i | tee -a ${LOG}
end

cd ${PUBRPTS}
source ./Configuration
cd weekly
foreach i (MGI_GeneOMIM.py MGI_OMIM.py MGI_GenePheno.py MGI_DO.py)
    echo `date`: $i | tee -a ${LOG}
    $i | tee -a ${LOG}
end

echo `date`: End nightly QC reports | tee -a ${LOG}
