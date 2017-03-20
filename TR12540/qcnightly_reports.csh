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

foreach i (MRK_GOUnknown.sql GXD_OrphanGenotype.sql)
    echo `date`: $i | tee -a ${LOG}
    ${QCRPTS}/reports.csh $i ${QCOUTPUTDIR}/$i.rpt ${MGD_DBSERVER} ${MGD_DBNAME}
end

foreach i (GO_Combined_Report.py MRK_GOIEA.py)
    echo `date`: $i | tee -a ${LOG}
    $i | tee -a ${LOG}
end

cd ${QCWEEKLY}

foreach i (VOC_DOAnnotNotInSlim.sql VOC_DOObsolete.sql)
    echo `date`: $i | tee -a ${LOG}
    ${QCRPTS}/reports.csh $i ${QCOUTPUTDIR}/$i.rpt ${MGD_DBSERVER} ${MGD_DBNAME}
end

foreach i (ALL_Progress.py ALL_DONoMP.py VOC_OMIMDOMult.py VOC_OMIMDOObsolete.py VOC_OMIMGenotypeNoMapDO.py)
    echo `date`: $i | tee -a ${LOG}
    $i | tee -a ${LOG}
end

cd ${PUBRPTS}
source ./Configuration
cd weekly
foreach i (MGI_DO.py MGI_GenePheno.py MGI_iphone_app.py)
    echo `date`: $i | tee -a ${LOG}
    $i | tee -a ${LOG}
end
#cd ${PUBRPTS}/mgimarkerfeed
#./mgimarkerfeed_reports.csh

echo `date`: End nightly QC reports | tee -a ${LOG}
