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
COPY (
(
select a._allele_key, a.symbol
        from MGI_Note n, MGI_NoteChunk c, ALL_Allele a, MRK_Marker m,
		MGI_Note mn, MGI_NoteChunk mnc
        where n._NoteType_key = 1034 
        and n._Object_key = a._Allele_key
        and n._Note_key = c._Note_key
        and a._Marker_key = m._Marker_key
	and mn._NoteType_key = 1021 
	and mn._Object_key = a._Allele_key
	and mn._Note_key = mnc._Note_key
	and not exists (select 1 from MGI_Relationship r
        	where a._Allele_key = r._Object_key_1
        	and r._Category_key = 1006
        	)
union
select a._allele_key, a.symbol
        from MGI_Note n, MGI_NoteChunk c, ALL_Allele a, MRK_Marker m
        where n._NoteType_key = 1034 
        and n._Note_key = c._Note_key
        and n._Object_key = a._Allele_key
        and a._Marker_key = m._Marker_key
	and not exists (select 1 from MGI_Note mn where mn._NoteType_key = 1021 and a._Allele_key = mn._Object_key)
	and not exists (select 1 from MGI_Relationship r
        	where a._Allele_key = r._Object_key_1
        	and r._Category_key = 1006
        	)
)
order by symbol
TO STDOUT (DELIMITER '|')
;


EOSQL

date |tee -a $LOG

