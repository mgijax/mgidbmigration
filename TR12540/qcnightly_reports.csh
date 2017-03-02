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

#foreach i ()
#    echo `date`: $i | tee -a ${LOG}
#    ${QCRPTS}/reports.csh $i ${QCOUTPUTDIR}/$i.rpt ${MGD_DBSERVER} ${MGD_DBNAME}
#end

#foreach i ()
#    echo `date`: $i | tee -a ${LOG}
#    $i | tee -a ${LOG}
#end

cd ${QCWEEKLY}

foreach i (VOC_DOAnnotNotInSlim.sql VOC_OMIMObsolete.sql)
    echo `date`: $i | tee -a ${LOG}
    ${QCRPTS}/reports.csh $i ${QCOUTPUTDIR}/$i.rpt ${MGD_DBSERVER} ${MGD_DBNAME}
end

foreach i (ALL_OMIMNoMP.py VOC_OMIMDOMult.py VOC_OMIMDOObsolete.py VOC_OMIMGenotypeNoMapDO.py)
    echo `date`: $i | tee -a ${LOG}
    $i | tee -a ${LOG}
end

cd ${PUBRPTS}
source ./Configuration
cd weekly
foreach i (MGI_OMIM.py MGI_DO.py MGI_GenePheno.py MGI_iphone_app.py)
    echo `date`: $i | tee -a ${LOG}
    $i | tee -a ${LOG}
end
#cd ${PUBRPTS}/mgimarkerfeed
#./mgimarkerfeed_reports.csh

echo `date`: End nightly QC reports | tee -a ${LOG}
