#!/bin/csh -f

#
# qcnightly_reports.csh
#
# Script to generate nightly QC reports.
#
# Usage: qcnightly_reports.csh
#

cd `dirname $0` && source ./Configuration

setenv LOG ${QCLOGSDIR}/`basename $0`.log
rm -rf ${LOG}
touch ${LOG}

echo `date`: Start nightly QC reports | tee -a ${LOG}

cd ${QCMGD}

foreach i (GXD_NotInCache.sql GXD_SpecNoAge.sql GXD_SpecTheiler.sql RECOMB_SpecTheiler.sql RECOMB_SpecNoAge.sql)
    echo `date`: $i | tee -a ${LOG}
    ${QCRPTS}/reports.csh $i ${QCOUTPUTDIR}/$i.rpt ${MGD_DBSERVER} ${MGD_DBNAME}
end

foreach i (GXD_SpecTheilerAge.py GXD_EMAPS_Terms.py GXD_Stats.py RECOMB_SpecTheilerAge.py GXD_ExpPresNotPres.py GXD_ChildExpNotParent)
    echo `date`: $i | tee -a ${LOG}
    $i >>& ${LOG}
end

cd ../monthly

foreach i (GXD_StatsMonthly.py)
    echo `date`: $i | tee -a ${LOG}
    $i >>& ${LOG}
end

echo `date`: End nightly QC reports | tee -a ${LOG}
