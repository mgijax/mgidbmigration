#!/bin/csh -f

#
# driver notes
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

        select distinct a._allele_key, a.symbol, m._marker_key, m.symbol, rtrim(c.note)
        from mgi_note n, mgi_notechunk c, all_allele a, mrk_marker m
        where n._notetype_key = 1034 
        and n._note_key = c._note_key
        and n._object_key = a._allele_key
        and a._marker_key = m._marker_key
	and m.symbol != rtrim(c.note)
        -- recombinase attribute/subtype
        and exists (select 1 from VOC_Annot va
                where va._AnnotType_key = 1014
                and a._Allele_key = va._Object_key
                and va._Term_key = 11025588
                )
        -- Targeted, Endonuclease/mediated
        and a._Allele_Type_key in (847116, 11927650)
        and a.symbol not like 'Gt(ROSA)%'
        and a.symbol not like 'Hprt<%'
        and a.symbol not like 'Col1a1<%'
        and a.symbol not like 'Evx2/Hoxd13<tm4(cre)Ddu>'
order by a.symbol
;

        select distinct a._allele_key, a.symbol, m._marker_key, m.symbol, rtrim(c.note)
        from mgi_note n, mgi_notechunk c, all_allele a, mrk_marker m
        where n._notetype_key = 1034 
        and n._note_key = c._note_key
        and n._object_key = a._allele_key
        and a._marker_key = m._marker_key
        -- recombinase attribute/subtype
        and exists (select 1 from VOC_Annot va
                where va._AnnotType_key = 1014
                and a._Allele_key = va._Object_key
                and va._Term_key = 11025588
                )
        -- Targeted, Endonuclease/mediated
        and a._Allele_Type_key in (847116, 11987835)
        and a.symbol not like 'Gt(ROSA)%'
        and a.symbol not like 'Hprt<%'
        and a.symbol not like 'Col1a1<%'
        and a.symbol not like 'Evx2/Hoxd13<tm4(cre)Ddu>'
order by a.symbol
;

EOSQL

date |tee -a $LOG

