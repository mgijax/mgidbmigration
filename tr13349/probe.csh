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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd PRB_Marker ${MGI_LIVE}/dbutils/mgidbmigration/tr13349/PRB_Marker.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd PRB_Notes ${MGI_LIVE}/dbutils/mgidbmigration/tr13349/PRB_Marker.bcp "|"

${PG_MGD_DBSCHEMADIR}/index/PRB_Marker_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/PRB_Notes_drop.object | tee -a $LOG 

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.PRB_Marker DROP CONSTRAINT PRB_Marker_pkey CASCADE;
ALTER TABLE mgd.PRB_Marker DROP CONSTRAINT PRB_Marker__Probe_key_fkey CASCADE;
ALTER TABLE mgd.PRB_Marker DROP CONSTRAINT PRB_Marker__Marker_key_fkey CASCADE;
ALTER TABLE mgd.PRB_Marker DROP CONSTRAINT PRB_Marker__Refs_key_fkey CASCADE;
ALTER TABLE PRB_Marker RENAME TO PRB_Marker_old;

ALTER TABLE mgd.PRB_Notes DROP CONSTRAINT PRB_Notes_pkey CASCADE;
ALTER TABLE mgd.PRB_Notes_Notes__Probe_key_fkey CASCADE;
ALTER TABLE PRB_Notes RENAME TO PRB_Notes_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/PRB_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/PRB_Notes_create.object | tee -a $LOG || exit 1

# autosequence
${PG_MGD_DBSCHEMADIR}/autosequence/PRB_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/PRB_Notes_create.object | tee -a $LOG || exit 1

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into PRB_Marker
select nextval('prb_marker_seq'), m._Probe_key, m._Marker_key, m._Refs_key, m.relationship, m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from PRB_Marker_old m
;

insert into PRB_Notes
select nextval('prb_notes_seq'), m._Probe_key, m.note, m.creation_date, m.modification_date
from PRB_Notes_old m
;

EOSQL

${PG_MGD_DBSCHEMADIR}/key/PRB_Marker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/PRB_Notes_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/PRB_Probe_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_Refs_drop.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/index/PRB_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/PRB_Notes_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/PRB_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/PRB_Notes_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/PRB_Probe_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_Refs_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from PRB_Marker_old;
select count(*) from PRB_Marker;

select count(*) from PRB_Notes_old;
select count(*) from PRB_Notes;

drop table mgd.PRB_Marker_old;
drop table mgd.PRB_Notes_old;

-- delete "Not Loaded" terms
--_segmenttype_key
--select * from voc_term where _vocab_key = 10;
delete from voc_term where _term_key = 74802;
--_vector_key
--select * from voc_term where _vocab_key = 24;
delete from voc_term where _term_key = 316371;
--select * from voc_term where _vocab_key = 147;
--age
delete from voc_term where _term_key = 64242117;
--select * from voc_term where _vocab_key = 17;
update prb_source set _gender_key = 315168 where _gender_key = 315170;
delete from voc_term where _term_key = 315170;

EOSQL

date |tee -a $LOG

