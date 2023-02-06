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

-- Non-mouse_Organism does not exist in MGI
select m._Marker_key, m.symbol as msymbol, a.symbol as asymbol, p1.value
from MRK_Marker m, MGI_Relationship r, ALL_Allele a, MGI_Relationship_Property p1
where r._Object_key_2 = m._Marker_key
and r._Category_key = 1004
and r._Object_key_1 = a._Allele_key
and r._Relationship_key = p1._Relationship_key
and p1._PropertyName_key = 12948290
and not exists (select 1 from MGI_Organism o where lower(p1.value) = lower(o.commonname))
order by p1.value, m.symbol
;

-- Non-mouse_NCBI_Gene_ID row exists
-- NCBI id does not exist in MGI
select m._Marker_key, m.symbol as msymbol, a.symbol as asymbol, p1.value
from MRK_Marker m, MGI_Relationship r, ALL_Allele a,
MGI_Relationship_Property p1
where r._Object_key_2 = m._Marker_key
and r._Category_key = 1004
and r._Object_key_1 = a._Allele_key
and r._Relationship_key = p1._Relationship_key
and p1._PropertyName_key = 12948292
and not exists (select 1 from ACC_Accession aa where aa._MGIType_key = 2 and aa._LogicalDB_key = 55 and aa.accid = p1.value)
order by m.symbol
;

-- rows still exist in MGI_Relationship_Property after migration
-- Non-mouse_Organism row exists
-- Non-mouse_Gene_Symbol row exists
select distinct m._Marker_key, m.symbol as msymbol, a.symbol as asymbol, p1.value as Non_mouse_Organism, p2.value as Non_mouse_Gene_Symbol
from MRK_Marker m, MGI_Relationship r, ALL_Allele a,
MGI_Relationship_Property p1, MGI_Organism o,
MGI_Relationship_Property p2
where r._Object_key_2 = m._Marker_key
and r._Category_key = 1004
and r._Object_key_1 = a._Allele_key
and r._Relationship_key = p1._Relationship_key
and p1._PropertyName_key = 12948290
and r._Relationship_key = p2._Relationship_key
and p2._PropertyName_key = 12948291
order by p1.value, p2.value, m.symbol
;

--and a._allele_key = 5949

EOSQL

