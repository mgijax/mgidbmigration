#!/bin/csh -f

#
# driver notes
#
# non-mouse : marker = yes, mol note = yes
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

select a.symbol as organizer, m.symbol as participant,
c.name, t1.name as vocab, t2.term as relterm, t3.term as qualifier, t4.term as evidence,  b.jnumID
from MGI_Relationship r, MGI_Relationship_Category c, ALL_Allele a, MRK_Marker m, 
VOC_Vocab t1, VOC_Term t2, VOC_Term t3, VOC_Term t4, BIB_Citation_Cache b
where r._Category_key = 1006
and r._Category_key = c._Category_key
and c._RelationshipVocab_key = t1._Vocab_key
and r._Object_key_1 = a._Allele_key
and r._Object_key_2 = m._Marker_key
and r._RelationshipTerm_key = t2._Term_key
and r._Qualifier_key = t3._Term_key
and r._Evidence_key = t4._Term_key
and r._Refs_key = b._Refs_key
order by a.symbol
;

EOSQL

date |tee -a $LOG

