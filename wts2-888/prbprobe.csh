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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd PRB_Probe ${MGI_LIVE}/dbutils/mgidbmigration/wts2-888/PRB_Probe.bcp "|"

${PG_MGD_DBSCHEMADIR}/index/PRB_Probe_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/PRB_Probe_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_User_drop.object | tee -a $LOG

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

select n.note, p._probe_key, a.accid
from prb_probe p, prb_notes n, acc_accession a
where p._probe_key = n._probe_key
and n.note like '%MGI:%'
and p._probe_key = a._object_key
and a._mgitype_key = 3
and a._logicaldb_key = 1
;

update prb_probe p
set ampPrimer = a._object_key
from prb_notes n, acc_accession a
where p._probe_key = n._probe_key
and n.note like '%MGI:%'
and p._probe_key = a._object_key
and a._mgitype_key = 3
and a._logicaldb_key = 1
;

EOSQL

${PG_MGD_DBSCHEMADIR}/key/PRB_Probe_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/PRB_Probe_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/comments/PRB_Probe_create.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from PRB_Probe_old;
select count(*) from PRB_Probe;

drop table PRB_Probe_old;
EOSQL

date |tee -a $LOG

