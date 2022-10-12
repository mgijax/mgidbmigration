#!/bin/csh -f

# pgmgddbschema
# pwi
# mgd_java_api
# probeload

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd PRB_Probe ${MGI_LIVE}/dbutils/mgidbmigration/wts2-888/PRB_Probe.bcp "|"

${PG_MGD_DBSCHEMADIR}/index/PRB_Probe_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/PRB_Probe_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_User_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/PRB_Source_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/trigger/PRB_Probe_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/PRB_drop.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/GXD_GenotypeAnnotHeader_View_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/GXD_ProbePrep_View_drop.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE PRB_Probe RENAME TO PRB_Probe_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/PRB_Probe_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/autosequence/PRB_Probe_create.object | tee -a $LOG 

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into PRB_Probe
select _probe_key, name, derivedFrom, null, _source_key, _vector_key, _segmenttype_key, 
primer1sequence, primer2sequence, regioncovered, insertsite, insertsize, productsize,
_createdby_key, _modifiedby_key, creation_date , modification_date
from PRB_Probe_old
;

EOSQL

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from PRB_Probe_old;
select count(*) from PRB_Probe;
drop table PRB_Probe_old;
EOSQL

${PG_MGD_DBSCHEMADIR}/key/PRB_Probe_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/PRB_Source_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/trigger/PRB_Probe_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/PRB_create.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/GXD_GenotypeAnnotHeader_View_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/GXD_ProbePrep_View_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/PRB_Probe_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/comments/PRB_Probe_create.object | tee -a $LOG

$PYTHON prbampprimer.py | tee -a $LOG

wc -l migrationIDs.txt | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from prb_probe where ampprimer is not null
EOSQL

date |tee -a $LOG

