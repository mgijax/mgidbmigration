#!/bin/csh -f

#
# mirror_wget
# vocload
# uniprotload
#
# J:345062
# ldb = 233
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
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- 02/16/2024: added to Production
--insert into voc_vocab values(188,664937,233,1,0,'GlyGen/UniProtKB',now(), now());
--insert into voc_annottype values(1030,2,188,139,53,'GlyGen/Marker',now(),now());

update voc_Term set abbreviation = 'NA'  where _term_key = 47380031;

-- for testing; remove old annotations/vocabulary terms
delete from voc_annot where _annottype_key = 1030;
delete from acc_accession where _mgitype_key = 13 and _logicaldb_key = 233;
delete from voc_term where _vocab_key = 188;

EOSQL

#${MIRROR_WGET}/download_package data.glygen.org

mkdir -p ${DATALOADSOUTPUT}/mgi/vocload/runTimeGlyGen
mkdir -p ${DATALOADSOUTPUT}/mgi/vocload/archiveGlyGen

# just to test GlyGen or run all
# chose one
${UNIPROTLOAD}/bin/makeGlyGenAnnot.sh
#${UNIPROTLOAD}/bin/uniprotload.sh

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- vocabulary
select a._accession_key, a.accid, t._term_key, t.term
from voc_term t, acc_accession a
where t._vocab_key = 188
and t._term_key = a._object_key
and a._mgitype_key = 13
and a._logicaldb_key = 233
order by a.accid
;

-- annotations
select a.accid, m._marker_key, m.symbol, t.term
from voc_annot va, mrk_marker m, voc_term t, acc_accession a
where va._annottype_key = 1030
and va._object_key = m._marker_key
and va._term_key = t._term_key
and t._vocab_key = 188
and t._term_key = a._object_key
and a._mgitype_key = 13
and a._logicaldb_key = 233
order by a.accid
;

EOSQL

date |tee -a $LOG
