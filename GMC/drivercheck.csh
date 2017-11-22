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

\echo ''
\echo 'all MGI_Relationship'
\echo ''

select a.symbol as organizer, m.symbol as participant, m._Organism_key, b.jnumID
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

\echo ''
\echo 'drivermouse that are not in MGI_Relationship'
\echo 'no molecular reference'
\echo ''
select distinct a._Allele_key, a.symbol, m._Marker_key, m.symbol, rtrim(c.note)
        from MGI_Note n, MGI_NoteChunk c, ALL_Allele a, MRK_Marker m
        where n._NoteType_key = 1034 
        and n._Note_key = c._Note_key
        and n._Object_key = a._Allele_key
        and a._Marker_key = m._Marker_key
	and a._Allele_Status_key != 847112
        and exists (select 1 from VOC_Annot va
                where va._AnnotType_key = 1014 
                and a._Allele_key = va._Object_key
                and va._Term_key = 11025588
                )
        and a._Allele_Type_key in (847116, 11927650)
        and a.symbol not like 'Gt(ROSA)%'
        and a.symbol not like 'Hprt<%'
        and a.symbol not like 'Col1a1<%'
        and a.symbol not like 'Evx2/Hoxd13<tm4(cre)Ddu>'
	and not exists (select 1 from MGI_Relationship r
        	where a._Allele_key = r._Object_key_1
        	and r._Category_key = 1006
        	)
	;


\echo ''
\echo 'MGI_Relationship that are not in drivermouse'
\echo 'no drive note'
\echo ''
select a.symbol as organizer, m.symbol as participant, m._Organism_key, b.jnumID
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
and not exists (select 1 from MGI_Note n, MGI_NoteChunk c
        where n._NoteType_key = 1034 
        and n._Note_key = c._Note_key
        and a._Allele_key = n._Object_key
	and a._Allele_Status_key != 847112
        and a._Allele_Type_key in (847116, 11927650)
        and a.symbol not like 'Gt(ROSA)%'
        and a.symbol not like 'Hprt<%'
        and a.symbol not like 'Col1a1<%'
        and a.symbol not like 'Evx2/Hoxd13<tm4(cre)Ddu>'
        and exists (select 1 from VOC_Annot va
                where va._AnnotType_key = 1014 
                and a._Allele_key = va._Object_key
                and va._Term_key = 11025588
                )
	)
;

\echo ''
\echo 'drivers that are not in MGI_Relationship'
\echo ''
select distinct a._Allele_key, a.symbol, m._Marker_key, m.symbol, rtrim(c.note)
        from MGI_Note n, MGI_NoteChunk c, ALL_Allele a, MRK_Marker m
        where n._NoteType_key = 1034 
        and n._Note_key = c._Note_key
        and n._Object_key = a._Allele_key
        and a._Marker_key = m._Marker_key
	and not exists (select 1 from MGI_Relationship r
        	where a._Allele_key = r._Object_key_1
        	and r._Category_key = 1006
        	)
	order by a.symbol
	;


EOSQL

date |tee -a $LOG

