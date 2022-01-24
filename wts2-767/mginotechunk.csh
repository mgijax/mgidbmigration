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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd MGI_Note ${MGI_LIVE}/dbutils/mgidbmigration/wts2-767/MGI_Note.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd MGI_NoteChunk ${MGI_LIVE}/dbutils/mgidbmigration/wts2-767/MGI_NoteChunk.bcp "|"

${PG_MGD_DBSCHEMADIR}/index/MGI_Note_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/MGI_Note_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_NoteType_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_User_drop.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE MGI_Note RENAME TO MGI_Note_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/MGI_Note_create.object | tee -a $LOG 

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into MGI_Note
select m._Note_key, m._Object_key, m._MGIType_key, m._NoteType_key, c.note, m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from MGI_Note_old m, MGI_NoteChunk c
where m._Note_key = c._Note_key
;

EOSQL

${PG_MGD_DBSCHEMADIR}/autosequence/MGI_Note_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/MGI_Note_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/MGI_Note_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_NoteType_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from MGI_Note_old;
select count(*) from MGI_Note;
select count(*) from MGI_NoteChunk;

drop table MGI_NoteChunk;
drop table MGI_Note_old;

EOSQL

date |tee -a $LOG

