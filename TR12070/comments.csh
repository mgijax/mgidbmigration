#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
${MGD_DBSCHEMADIR}/comments/comments_create.sh | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

drop view mgi_table_column_view;
drop table MGI_Columns;
drop table MGI_Tables;

EOSQL

date |tee -a $LOG

