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
\echo 'drivers that are not in MGI_Relationship'
\echo 'SHOULD BE ZERO'
\echo ''

select distinct a._Allele_key, a.symbol, m._Marker_key, m.symbol, rtrim(c.note)
        from ALL_Allele a, MRK_Marker m, MGI_Note n, MGI_NoteChunk c
	where a._Marker_key = m._Marker_key
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

select distinct a._Allele_key, a.symbol, m._Marker_key, m.symbol, null
        from ALL_Allele a, MRK_Marker m
	where a._Marker_key = m._Marker_key

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

EOSQL

date |tee -a $LOG
        
