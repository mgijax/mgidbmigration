#!/bin/csh -f

#
# has tr12963 branch:
# ei
# pgmgddbschema
# mgipython
# nomenload
# reports_db
#


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
#
# MRK_Current : removing
#
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd MRK_Current ${MGI_LIVE}/dbutils/mgidbmigration/tr12963/MRK_Current.bcp "|"
${PG_MGD_DBSCHEMADIR}/trigger/MRK_Marker_drop.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

DROP FUNCTION IF EXISTS MRK_simpleWithdrawal(int,int,int,int,text,text,int);
DROP FUNCTION IF EXISTS MRK_mergeWithdrawal(int,int,int,int,int,int,int);
drop view if exists mgd.MRK_Current_View;

ALTER TABLE mgd.MRK_Current DROP CONSTRAINT MRK_Current__Current_key_fkey CASCADE;
ALTER TABLE mgd.MRK_Current DROP CONSTRAINT MRK_Current__Marker_key_fkey CASCADE;

drop table mgd.MRK_Current;

EOSQL

${PG_MGD_DBSCHEMADIR}/trigger/MRK_Marker_create.object | tee -a $LOG || exit 1

date |tee -a $LOG

