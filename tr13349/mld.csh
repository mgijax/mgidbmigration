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

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE MLD_Expt_Marker RENAME TO MLD_Expt_Marker_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/MLD_Expt_Marker_create.object | tee -a $LOG 

# autosequence
${PG_MGD_DBSCHEMADIR}/autosequence/MLD_Assay_Types_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/autosequence/MLD_Expts_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/autosequence/MLD_Expt_Marker_create.object | tee -a $LOG 

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into MLD_Expt_Marker
select nextval('mld_expt_marker_seq'), m._Expt_key, m._Marker_key, m._Allele_key, m._Assay_Type_key,
m.sequenceNum, m.description, m.matrixdata,
m.creation_date, m.modification_date
from MLD_Expt_Marker_old m
;

EOSQL

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

delete from mld_assay_types where _assay_type_key in (129, 130);

select count(*) from MLD_Expt_Marker_old;
select count(*) from MLD_Expt_Marker;

drop table MLD_Expt_Marker_old;

EOSQL

date |tee -a $LOG

