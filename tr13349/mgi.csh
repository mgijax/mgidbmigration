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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd MGI_Organism_MGIType ${MGI_LIVE}/dbutils/mgidbmigration/tr13349/MGI_Organism_MGIType.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd PWI_Report ${MGI_LIVE}/dbutils/mgidbmigration/tr13349/PWI_Report.bcp "|"

${PG_MGD_DBSCHEMADIR}/index/MGI_Organism_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/MGI_Organism_MGIType_drop.object | tee -a $LOG 

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE MGI_Organism_MGIType RENAME TO MGI_Organism_MGIType_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/MGI_Organism_MGIType_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/autosequence/MGI_Organism_MGIType_create.object | tee -a $LOG 

#
#insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into MGI_Organism_MGIType
select nextval('mgi_organism_mgitype_seq'), m._organism_key, m._mgitype_key, m.sequenceNum,
m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from MGI_Organism_MGIType_old m
;

delete from mgi_organism_mgitype where _mgitype_key in (18, 19)
;

EOSQL

${PG_MGD_DBSCHEMADIR}/index/MGI_Organism_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/MGI_Organism_MGIType_create.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from MGI_Organism_MGIType_old;
select count(*) from MGI_Organism_MGIType;

update acc_logicaldb set _organism_key = 76 where _organism_key is null;
drop table mgi_organism_mgitype_old;
delete from gxd_assaytype where _assaytype_key in (-1,-2);
-- remove obsolete pwi_report
delete from pwi_report where id in (9,10,11,12,13,36,17);

EOSQL

# obsolete reports
rm -rf ${QCREPORTDIR}/output/WF_AP_Routed.rpt

date |tee -a $LOG

