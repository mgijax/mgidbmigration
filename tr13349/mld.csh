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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd MLD_Expt_Marker ${MGI_LIVE}/dbutils/mgidbmigration/tr13349/MLD_Expt_Marker.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd MLD_Expt_Notes ${MGI_LIVE}/dbutils/mgidbmigration/tr13349/MLD_Expt_Notes.bcp "|"

${PG_MGD_DBSCHEMADIR}/index/MLD_Expt_Marker_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/MLD_Expt_Notes_drop.object | tee -a $LOG 

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.MLD_Expt_Marker DROP CONSTRAINT MLD_Expt_Marker_pkey CASCADE;
ALTER TABLE mgd.MLD_Expt_Marker DROP CONSTRAINT MLD_Expt_Marker__Expt_key_fkey CASCADE;
ALTER TABLE mgd.MLD_Expt_Marker DROP CONSTRAINT MLD_Expt_Marker__Marker_key_fkey CASCADE;
ALTER TABLE mgd.MLD_Expt_Marker DROP CONSTRAINT MLD_Expt_Marker__Allele_key_fkey CASCADE;
ALTER TABLE mgd.MLD_Expt_Marker DROP CONSTRAINT MLD_Expt_Marker__Assay_Type_key_fkey CASCADE;
ALTER TABLE MLD_Expt_Marker RENAME TO MLD_Expt_Marker_old;

ALTER TABLE mgd.MLD_Expt_Notes DROP CONSTRAINT MLD_Expt_Notes_pkey CASCADE;
ALTER TABLE MLD_Expt_Notes RENAME TO MLD_Expt_Notes_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/MLD_Expt_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/MLD_Expt_Notes_create.object | tee -a $LOG || exit 1

# autosequence
${PG_MGD_DBSCHEMADIR}/autosequence/MLD_Assay_Types_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/MLD_Expts_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/MLD_Expt_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/MLD_Expt_Notes_create.object | tee -a $LOG || exit 1

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into MLD_Expt_Marker
select nextval('mld_expt_marker_seq'), m._Expt_key, m._Marker_key, m._Allele_key, m._Assay_Type_key,
m.sequenceNum, m.gene, m.description, m.matrixdata,
m.creation_date, m.modification_date
from MLD_Expt_Marker_old m
;

insert into MLD_Expt_Notes
select nextval('mld_expt_notes_seq'), m._Expt_key, m.note, m.creation_date, m.modification_date
from MLD_Expt_Notes_old m
;

EOSQL

${PG_MGD_DBSCHEMADIR}/key/MLD_Assay_Types_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MLD_Expt_Marker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MLD_Expt_Notes_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MLD_Expts_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/ALL_Allele_drop.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/index/MLD_Expt_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/MLD_Expt_Notes_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/MLD_Assay_Types_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MLD_Expt_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MLD_Expt_Notes_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MLD_Expts_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/ALL_Allele_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from MLD_Expt_Marker_old;
select count(*) from MLD_Expt_Marker;

select count(*) from MLD_Expt_Notes_old;
select count(*) from MLD_Expt_Notes;

drop table mgd.MLD_Expt_Marker_old;
drop table mgd.MLD_Expt_Notes_old;

EOSQL

date |tee -a $LOG

