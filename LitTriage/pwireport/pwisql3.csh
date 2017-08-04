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

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select a.accID, r.journal, 1 as relevance
from BIB_Refs r, ACC_Accession a
where r.isDiscard = 0
and r._Refs_key = a._Object_key
and a._MGIType_key = 1
and a._LogicalDB_key = 1
and a.prefixPart = 'MGI:'
and r.journal in ('Nat Neurosci','Neurobiol Aging','Neuroscience')
and exists (select ws._Refs_key from BIB_Workflow_Status ws, VOC_Term wst
	where r._Refs_key = ws._Refs_Key
	and ws._Status_key = wst._Term_key
	and wst.term in ('Not Routed')
	and ws.isCurrent = 1
	group by _Refs_key having count(*) = 5
	)

and not exists (select 1 from BIB_Workflow_Tag wt, VOC_Term wtt
	where r._Refs_key = wt._Refs_key
	and wt._Tag_key = wtt._Term_key
	and lower(wtt.term) like 'mgi:curator_%')
union

select a.accID, r.journal, 2 as relevance
from BIB_Refs r, ACC_Accession a
where r.isDiscard = 0
and r._Refs_key = a._Object_key
and a._MGIType_key = 1
and a._LogicalDB_key = 1
and a.prefixPart = 'MGI:'
and r.journal not in ('Nat Neurosci','Neurobiol Aging','Neuroscience')
and r.journal not in ('J Biol Chem','Biochem J')
and r.journal not in ('Development','Dev Biol','Dev Dyn','Mech Dev','Genes Dev','Gene Expr Patterns','Dev Cell','BMC Dev Biol')
and r.journal not in ('Cancer Cell','Cancer Discov','Cancer Lett','Cancer Res','Carcinogenesis','Int J Cancer','J Natl Cancer Inst','Leukemia','Mol Cancer Res','Nat Rev Cancer','Oncogene','Semin Cancer Biol')
and exists (select ws._Refs_key from BIB_Workflow_Status ws, VOC_Term wst
	where r._Refs_key = ws._Refs_Key
	and ws._Status_key = wst._Term_key
	and wst.term in ('Not Routed')
	and ws.isCurrent = 1
	group by _Refs_key having count(*) = 5
	)

and not exists (select 1 from BIB_Workflow_Tag wt, VOC_Term wtt
	where r._Refs_key = wt._Refs_key
	and wt._Tag_key = wtt._Term_key
	and lower(wtt.term) like 'mgi:curator_%')
)
order by relevance, accID
limit 200
;

EOSQL
