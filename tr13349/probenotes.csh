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

${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd PRB_Notes ${MGI_LIVE}/dbutils/mgidbmigration/tr13349/PRB_Notes.bcp "|"

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
delete from MGI_Note where _notetype_key = 1052;
EOSQL

${PYTHON} probenotes.py | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/MGI_NoteChunk_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/MGI_Note_drop.object | tee -a $LOG
${NOTELOAD}/mginoteload.csh ${MGI_LIVE}/dbutils/mgidbmigration/tr13349/probenotes.config
${PG_MGD_DBSCHEMADIR}/index/MGI_NoteChunk_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/MGI_Note_create.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from MGI_Note where _notetype_key = 1052
select count(*) from PRB_Notes;

--drop table mgd.PRB_Notes;

EOSQL

date |tee -a $LOG

