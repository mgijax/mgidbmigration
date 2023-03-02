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
 
#${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd MGI_Relationship ${MGI_LIVE}/dbutils/mgidbmigration/fl2b/MGI_Relationship.bcp "|"

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- delete
-- 12948293 | expresses_an_orthologous_gene
-- 12965808 | expresses_mouse_gene
-- 111135297 | expresses_non-orthologous_gene

-- keep
-- 12438346 | expresses_component

select t._term_key, t.term from voc_term t where t._term_key in (12948293, 12438346, 12965808, 111135297);

select count(*), _relationshipterm_key, t.term
from mgi_relationship r, voc_term t
where r._relationshipterm_key = t._term_key
and r._relationshipterm_key in (12948293, 12965808, 111135297, 12438346)
group by _relationshipterm_key, term;
;

-- move all MGI_Relationship expresses_an_orthologous_gene, expresses_mouse_gene -> expresses_component
update MGI_Relationship set _relationshipterm_key = 12438346 where _relationshipterm_key in (12948293, 12965808);
delete from VOC_Term where _term_key in (12948293,12965808,111135297);

select count(*), _relationshipterm_key, t.term
from mgi_relationship r, voc_term t
where r._relationshipterm_key = t._term_key
and r._relationshipterm_key in (12948293, 12965808, 111135297, 12438346)
group by _relationshipterm_key, term;
;

-- merge "has_driver" -> "driver_component"
update MGI_Relationship set _RelationshipTerm_key = 111172001 where _RelationshipTerm_key = 36770349;
update mgi_relationship_category set _relationshipvocab_key = 96 where _category_key = 1006;
delete from VOC_Term where _Vocab_key = 132;
delete from VOC_Vocab where _Vocab_key = 132;

EOSQL

# add new markers
$PYTHON esaddnsmarkers.py | tee -a $LOG
# move mgi_relationship_property to mgi_relationship
$PYTHON esproperties.py | tee -a $LOG
# add new driver components
$PYTHON esdriver.py | tee -a $LOG

date | tee -a $LOG

# check duplicates
esduplicates.csh | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- rows still exist in MGI_Relationship_Property after migration
-- if 0, then all Properties were successfully migrated
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

EOSQL

date |tee -a $LOG

