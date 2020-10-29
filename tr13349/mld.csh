#!/bin/csh -f

#
# TEXT-QTL
# TEXT-Physical Mapping
# TEXT-Congenic
# TEXT-QTL-Candidate Genes
# TEXT-Meta Analysis
# TEXT
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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd MLD_Expt_Marker ${MGI_LIVE}/dbutils/mgidbmigration/tr13349/MLD_Expt_Marker.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd MLD_Expt_Notes ${MGI_LIVE}/dbutils/mgidbmigration/tr13349/MLD_Expt_Notes.bcp "|"

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
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

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from MLD_Expt_Marker_old;
select count(*) from MLD_Expt_Marker;

select count(*) from MLD_Expt_Notes_old;
select count(*) from MLD_Expt_Notes;

drop table mgd.MLD_Expt_Marker_old;
drop table mgd.MLD_Expt_Notes_old;

EOSQL

date |tee -a $LOG

