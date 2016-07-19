#!/bin/csh -f

#
# qcnightly_reports.csh
#
# Script to generate nightly QC reports.
#
# Usage: qcnightly_reports.csh
#

cd `dirname $0` && source ${QCRPTS}/Configuration

setenv LOG ${QCLOGSDIR}/`basename $0`.log
rm -rf ${LOG}
touch ${LOG}

echo `date`: Start nightly QC reports | tee -a ${LOG}

cd ${QCMGD}

#foreach i ()
#    echo `date`: $i | tee -a ${LOG}
#    ${QCRPTS}/reports.csh $i ${QCOUTPUTDIR}/$i.rpt ${MGD_DBSERVER} ${MGD_DBNAME}
#end

foreach i (GXD_Stats.py)
    echo `date`: $i | tee -a ${LOG}
    $i >>& ${LOG}
end

cd ${PUBRPTS}
source ./Configuration
cd daily
foreach i (GO_gene_association.py GP_gpi.py)
    echo `date`: $i | tee -a ${LOG}
    $i >>& ${LOG}

echo `date`: End nightly QC reports | tee -a ${LOG}
