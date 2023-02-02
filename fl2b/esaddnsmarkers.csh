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
 
$PYTHON esaddnsmarkers.py | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select m._Marker_key, m.symbol as msymbol, a.symbol as asymbol, p1.value, p2.value as nssymbol, o._organism_key, o.commonname
from MRK_Marker m, MGI_Relationship r, ALL_Allele a,
MGI_Relationship_Property p1, MGI_Organism o,
MGI_Relationship_Property p2
where r._Object_key_2 = m._Marker_key
and r._Category_key = 1004
and r._Object_key_1 = a._Allele_key
and r._Relationship_key = p1._Relationship_key
and p1._PropertyName_key = 12948290
and p1.value = o.commonname
and p1.value = 'Not Specified'
and r._Relationship_key = p2._Relationship_key
and p2._PropertyName_key = 12948291
and exists (select 1 from MRK_Marker m where o._Organism_key = m._Organism_key and p2.value = m.symbol)
order by p1.value, p2.value, m.symbol
;

select m._Marker_key, m.symbol as msymbol, a.symbol as asymbol, p1.value, p2.value as nssymbol, o._organism_key, o.commonname
from MRK_Marker m, MGI_Relationship r, ALL_Allele a,
MGI_Relationship_Property p1, MGI_Organism o,
MGI_Relationship_Property p2
where r._Object_key_2 = m._Marker_key
and r._Category_key = 1004
and r._Object_key_1 = a._Allele_key
and r._Relationship_key = p1._Relationship_key
and p1._PropertyName_key = 12948290
and p1.value = o.commonname
and p1.value = 'Not Specified'
and r._Relationship_key = p2._Relationship_key
and p2._PropertyName_key = 12948291
and not exists (select 1 from MRK_Marker m where o._Organism_key = m._Organism_key and p2.value = m.symbol)
order by p1.value, p2.value, m.symbol
;

EOSQL

date |tee -a $LOG

