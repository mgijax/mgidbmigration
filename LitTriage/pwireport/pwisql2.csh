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


	select 'AP' as group, count(distinct r._Refs_key) as rCount
	from BIB_Refs r
	where r.journal in ('Nat Neurosci','Neurobiol Aging','Neuroscience')
	and r.isDiscard = 0
        and exists (select ws._Refs_key from BIB_Workflow_Status ws, VOC_Term wst 
                where r._Refs_key = ws._Refs_Key
                and ws._Status_key = wst._Term_key
                and wst.term in ('Not Routed')
		and ws.isCurrent = 1
		group by _Refs_key having count(*) = 5
                )
;

	select 'GO' as group, count(distinct r._Refs_key) as rCount
	from BIB_Refs r
	where r.journal in ('J Biol Chem','Biochem J')
	and r.isDiscard = 0
        and exists (select ws._Refs_key from BIB_Workflow_Status ws, VOC_Term wst 
                where r._Refs_key = ws._Refs_Key
                and ws._Status_key = wst._Term_key
                and wst.term in ('Not Routed')
		and ws.isCurrent = 1
		group by _Refs_key having count(*) = 5
                )
;
	select 'GXD' as group, count(distinct r._Refs_key) as rCount
	from BIB_Refs r
	where r.journal in ('Development','Dev Biol','Dev Dyn','Mech Dev','Genes Dev','Gene Expr Patterns','Dev Cell','BMC Dev Biol')
	and r.isDiscard = 0
        and exists (select ws._Refs_key from BIB_Workflow_Status ws, VOC_Term wst 
                where r._Refs_key = ws._Refs_Key
                and ws._Status_key = wst._Term_key
                and wst.term in ('Not Routed')
		and ws.isCurrent = 1
		group by _Refs_key having count(*) = 5
                )
;
	select 'Tumor' as group, count(distinct r._Refs_key) as rCount
	from BIB_Refs r
	where r.journal in ('Cancer Cell','Cancer Discov','Cancer Lett','Cancer Res','Carcinogenesis','Int J Cancer','J Natl Cancer Inst','Leukemia','Mol Cancer Res','Nat Rev Cancer','Oncogene','Semin Cancer Biol')
	and r.isDiscard = 0
        and exists (select ws._Refs_key from BIB_Workflow_Status ws, VOC_Term wst 
                where r._Refs_key = ws._Refs_Key
                and ws._Status_key = wst._Term_key
                and wst.term in ('Not Routed')
		and ws.isCurrent = 1
		group by _Refs_key having count(*) = 5
                )
;
	select 'Other' as group, count(distinct r._Refs_key) as rCount
	from BIB_Refs r
	where r.journal not in ('Nat Neurosci','Neurobiol Aging','Neuroscience',
	'Development','Dev Biol','Dev Dyn','Mech Dev','Genes Dev','Gene Expr Patterns','Dev Cell','BMC Dev Biol',
	'J Biol Chem','Biochem J',
	'Cancer Cell','Cancer Discov','Cancer Lett','Cancer Res','Carcinogenesis','Int J Cancer','J Natl Cancer Inst','Leukemia','Mol Cancer Res','Nat Rev Cancer','Oncogene','Semin Cancer Biol')
	and r.isDiscard = 0
        and exists (select ws._Refs_key from BIB_Workflow_Status ws, VOC_Term wst 
                where r._Refs_key = ws._Refs_Key
                and ws._Status_key = wst._Term_key
                and wst.term in ('Not Routed')
		and ws.isCurrent = 1
		group by _Refs_key having count(*) = 5
                )
;

EOSQL
