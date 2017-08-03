#!/bin/csh

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

select jnum, short_citation from BIB_GOXRef_View_old r where r._Marker_key = 10603
and not exists (select 1 from VOC_Annot a, VOC_Evidence e
where a._Annot_key = e._Annot_key
and e._Refs_key = r._Refs_key
and a._AnnotType_key = 1000)
order by r.jnum desc
;

select jnum, short_citation from BIB_GOXRef_View_old r where r._Marker_key = 10603
and not exists (select 1 from VOC_Annot a, VOC_Evidence e
where a._Annot_key = e._Annot_key
and e._Refs_key = r._Refs_key
and a._AnnotType_key = 1000)
and not exists (select 1 from BIB_Workflow_Status ws, VOC_Term wst1, VOC_Term wst2
        where r._Refs_key = ws._Refs_Key
        and ws._Group_key = wst1._Term_key
        and wst1.abbreviation in ('GO')
        and ws._Status_key = wst2._Term_key
        and wst2.term in ('Chosen', 'Routed')
        and ws.isCurrent = 1
        )

order by r.jnum desc
;

select r.jnum, r.short_citation, m._Marker_key, r.jnumID, r.title, r.creation_date
from MRK_Reference m, BIB_All_View r
where m._Refs_key = r._Refs_key
and exists (select 1 from BIB_Workflow_Status ws, VOC_Term wst1, VOC_Term wst2
        where r._Refs_key = ws._Refs_Key
        and ws._Group_key = wst1._Term_key
        and wst1.abbreviation in ('GO')
        and ws._Status_key = wst2._Term_key
        and wst2.term in ('Chosen', 'Routed')
        and ws.isCurrent = 1 
        )
and m._Marker_key = 10603
;

EOSQL
