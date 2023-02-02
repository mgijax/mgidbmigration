#
# to convert MGI_Relationship_Property to MGI_Relationship
#
# existing MGI_Relationship_Property for 1004 (expresses component)
# need to be convertred from using the mouse gene to the non-mouse gene
#
 
import sys 
import os
import db

db.setTrace()

# "categoryKey": "1004",
# "categoryTerm": "expresses_component",
# "organismKey": "1",
# "organism": "mouse, laboratory",
# "relationshipTermKey": "12948293",
# "relationshipTerm": "expresses_an_orthologous_gene",

results = db.sql('''
select m._marker_key as currentKey, m.symbol as msymbol, p1.value, h._marker_key as newKey, h.symbol, a.symbol as allelesymbol, r.*
from MRK_Marker m, MGI_Relationship r, ALL_Allele a,
MGI_Relationship_Property p1, MGI_Organism o,
MGI_Relationship_Property p2, MRK_Marker h
where r._object_key_2 = m._marker_key
and r._category_key = 1004
and r._relationshipterm_key = 12948293
and r._object_key_1 = a._allele_key
and r._relationship_key = p1._relationship_key
and p1._propertyName_key = 12948290
and lower(p1.value) = lower(o.commonname)
and r._relationship_key = p2._relationship_key
and p2._propertyName_key = 12948291
and o._organism_key = h._organism_key 
and p2.value = h.symbol
order by p1.value, p2.value, m.symbol
''', 'auto')

#addSQL = ""
updateSQL = ""
deleteSQL = ""
for r in results:

        print(r)

        # for testing, add a new record to see both old and new rows
        #addSQL += '''insert into mgi_relationship values(nextval('mgi_relationship_seq'),%s,%s,%s,%s,%s,%s,%s,%s,%s,'%s','%s');\n'''  \
        #        % (r['_category_key'], r['_object_key_1'], r['newKey'], r['_relationshipterm_key'], \
        #                r['_qualifier_key'], r['_evidence_key'], r['_refs_key'], \
        #                r['_createdby_key'], r['_modifiedby_key'], r['creation_date'], r['modification_date'])

        # for real, simply convert from mouse to non-mouse
        updateSQL += 'update MGI_Relationship set _object_key_2 = ' + str(r['newKey']) + ' where _relationship_key = ' + str(r['_relationship_key']) + ';\n';
        deleteSQL += 'delete from MGI_Relationship_Property where _relationship_key = ' + str(r['_relationship_key']) + ';\n';

#print(addSQL)
#print(updateSQL)
#print(deleteSQL)
#db.sql(addSQL, None)
db.sql(updateSQL, None)
db.sql(deleteSQL, None)
db.commit()

