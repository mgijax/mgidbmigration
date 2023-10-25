#!/bin/csh -f

#
# Template
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
 
# for testing
${PG_MGD_DBSCHEMADIR}/table/VOC_AnnotHeader_lec_truncate.object
loadTableData.csh mgi-testdb4 lec mgd VOC_AnnotHeader_lec /home/lec/mgi/dbutils/mgidbmigration-trunk/wts2-1236/VOC_AnnotHeader.bcp.bak "|"

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

DELETE from VOC_AnnotHeader_lec h WHERE NOT EXISTS (SELECT 1 FROM VOC_Annot g WHERE g._AnnotType_key = 1002 and h._object_key = g._object_key)
;

select count(*) from voc_annotheader;

-- terms in header that are not on header in production
select aa.accid, t.term
from voc_annotheader a, acc_accession aa, voc_term t
where a._object_key = aa._object_key
and aa._logicaldb_key = 1
and aa._mgitype_key = 12
and a._term_key = t._term_key
and not exists (select 1 from voc_annotheader_lec b
        where a._object_key = b._object_key
        and a._term_key = b._term_key
        )
order by aa.accid
;

-- terms that are in header on production but not on header in lec
select aa.accid, t.term
from voc_annotheader_lec a, acc_accession aa, voc_term t
where a._object_key = aa._object_key
and aa._logicaldb_key = 1
and aa._mgitype_key = 12
and a._term_key = t._term_key
and not exists (select 1 from voc_annotheader b
        where a._object_key = b._object_key
        and a._term_key = b._term_key
        )
order by aa.accid
;

EOSQL

date |tee -a $LOG

