#!/bin/csh -f

#
# qcnightly_reports.csh
#
# Script to generate nightly QC reports.
#
# Usage: qcnightly_reports.csh
#

echo `date`: Start nightly QC reports 

cd ${QCRPTS}
source ./Configuration

cd ${QCMGD}

#mgd/GXD_NotInCache.sql:where g._GelControl_key = 1
#mgd/GXD_SpecNoAge.sql:where s._GelControl_key = 1
#mgd/RECOMB_SpecNoAge.sql:where s._GelControl_key = 1
#mgd/GXD_ChildExpNotParent.py
#mgd/RECOMB_ChildExpNotParent.py

foreach i (GXD_NotInCache.sql GXD_SpecNoAge.sql RECOMB_SpecNoAge.sql)
    echo `date`: $i 
    ${QCRPTS}/reports.csh $i ${QCOUTPUTDIR}/$i.rpt ${PG_DBSERVER} ${PG_DBNAME}
end

#foreach i (GXD_ChildExpNotParent.py RECOMB_ChildExpNotParent.py)
#    echo `date`: $i 
#    ${PYTHON} $i 
#end

#monthly/GXD_DistinctAge.sql:where _gelcontrol_key = 1
#monthly/GXD_StatsMonthly.py:        and l._GelControl_key = 1

cd ${QCMONTHLY}

foreach i (GXD_DistinctAge.sql)
    echo `date`: $i 
    ${QCRPTS}/reports.csh $i ${QCOUTPUTDIR}/$i.rpt ${PG_DBSERVER} ${PG_DBNAME}
end

foreach i (GXD_StatsMonthly.py)
    echo `date`: $i 
    ${PYTHON} $i 
end

#weekly/GXD_GelBand.sql:where l._GelControl_key = 1

cd ${QCWEEKLY}

foreach i (GXD_GelBand.sql)
    echo `date`: $i 
    ${QCRPTS}/reports.csh $i ${QCOUTPUTDIR}/$i.rpt ${PG_DBSERVER} ${PG_DBNAME}
end

echo `date`: End nightly QC reports 
