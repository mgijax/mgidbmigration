#
# to convert MGI_Relationship_Property to MGI_Relationship
#
# existing MGI_Relationship_Property for 1004 (expresses component)
# need to be convertred from using the mouse gene to the non-mouse gene
#
# find the existing mouse (MGI_Relationship._object_key_2) and non-mouse (MGI_Relationship_Property)
#       update mgi_relationship set _object_key_2 = non-mouse symbol
#
 
import sys 
import os
import db

db.setTrace()

db.useOneConnection(1)

results = db.sql('''
select r._relationship_key, m._marker_key as currentKey, m.symbol as msymbol, p1.value, h._marker_key as newKey, h.symbol, a.symbol as allelesymbol
from MRK_Marker m, MGI_Relationship r, ALL_Allele a,
MGI_Relationship_Property p1, MGI_Organism o,
MGI_Relationship_Property p2, MRK_Marker h
where r._object_key_2 = m._marker_key
and r._category_key = 1004
and r._object_key_1 = a._allele_key
and r._relationship_key = p1._relationship_key
and p1._propertyName_key = 12948290
and p1.value = o.commonname
and r._relationship_key = p2._relationship_key
and p2._propertyName_key = 12948291
and o._organism_key = h._organism_key 
and p2.value = h.symbol
order by p1.value, p2.value, m.symbol
''', 'auto')

updateSQL = ""
deleteSQL = ""
for r in results:
        updateSQL += 'update MGI_Relationship set _object_key_2 = ' + str(r['newKey']) + ' where _relationship_key = ' + str(r['_relationship_key']) + ';\n';
        deleteSQL += 'delete from MGI_Relationship_Property where _relationship_key = ' + str(r['_relationship_key']) + ';\n';

print(updateSQL)
print(deleteSQL)
#db.sql(updateSQL, None)
#db.sql(deleteSQL, None)

db.useOneConnection(0)

