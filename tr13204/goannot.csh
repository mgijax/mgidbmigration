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

${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd VOC_Annot ${MGI_LIVE}/dbutils/mgidbmigration/tr13204/VOC_Annot.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd VOC_Evidence ${MGI_LIVE}/dbutils/mgidbmigration/tr13204/VOC_Evidence.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd VOC_Evidence_Property ${MGI_LIVE}/dbutils/mgidbmigration/tr13204/VOC_Evidence_Property.bcp "|"

${PG_MGD_DBSCHEMADIR}/trigger/VOC_Annot_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_drop.object | tee -a $LOG

./goannot.py | tee -a $LOG

${PG_MGD_DBSCHEMADIR}/trigger/VOC_Annot_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_create.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

WITH goAnnot AS (
select _object_key, _term_key, _qualifier_key
from voc_annot 
where _annottype_key = 1000 
group by _object_key, _term_key, _qualifier_key having count(*) > 1 
)
select a._annot_key, a._object_key, a._term_key, e._annotevidence_key, aa.accID, t.term
from voc_annot a, goAnnot m, voc_evidence e, voc_term t, acc_accession aa
where a._annottype_key = 1000
and a._object_key = m._object_key
and a._term_key = m._term_key
and a._annot_key = e._annot_key
and a._term_key = t._term_key
and a._object_key = aa._object_key
and aa._mgitype_key = 2
and aa._logicaldb_key = 1 
order by a._object_key, a._term_key, a._annot_key
;

EOSQL

date |tee -a $LOG

