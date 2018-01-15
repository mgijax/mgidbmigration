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

select a._Allele_key, a.symbol
into temp a
        from MGI_Note n, MGI_NoteChunk c, ALL_Allele a, MRK_Marker m
	where a._Allele_Status_key not in (847112)
        and n._NoteType_key = 1034
        and n._Object_key = a._Allele_key
        and n._Note_key = c._Note_key
        and a._Marker_key = m._Marker_key
        and not exists (select 1 from MGI_Relationship r
                where a._Allele_key = r._Object_key_1
                and r._Category_key = 1006
                )
;

select a._Allele_key, a.symbol
into temp b
        from ALL_Allele a, MRK_Marker m, MGI_Note n, MGI_NoteChunk c
	where a._Allele_Status_key not in (847112)
        and a._Marker_key = m._Marker_key
        and a._Allele_key = n._Object_key
        and n._NoteType_key = 1034 
        and n._Note_key = c._Note_key

        and exists (select 1 from VOC_Annot va
                where va._AnnotType_key = 1014 
                and a._Allele_key = va._Object_key
                and va._Term_key = 11025588
                )

        and not exists (select 1 from MGI_Relationship r
                where a._Allele_key = r._Object_key_1
                and r._Category_key = 1006
                )

union

select a._Allele_key, a.symbol
        from ALL_Allele a, MRK_Marker m
	where a._Allele_Status_key not in (847112)
        and a._Marker_key = m._Marker_key

        and not exists (select 1 from MGI_Note n
                where a._Allele_key = n._Object_key
                and n._NoteType_key = 1034 
                )

        and exists (select 1 from VOC_Annot va
                where va._AnnotType_key = 1014 
                and a._Allele_key = va._Object_key
                and va._Term_key = 11025588
                )

        and not exists (select 1 from MGI_Relationship r
                where a._Allele_key = r._Object_key_1
                and r._Category_key = 1006
                )
;

select b.* from b where not exists (select 1 from a where b._Allele_key = a._Allele_key)
;

EOSQL
