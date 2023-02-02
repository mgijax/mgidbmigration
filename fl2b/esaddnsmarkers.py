#
# to add Not Specified markers to MGI
#
 
import sys 
import os
import db

db.setTrace()

db.useOneConnection(1)

results = db.sql('''
select distinct m._Marker_key, m.symbol as msymbol, p1.value, p2.value as nssymbol, o._organism_key, o.commonname
from MRK_Marker m, MGI_Relationship r,
MGI_Relationship_Property p1, MGI_Organism o,
MGI_Relationship_Property p2
where r._Object_key_2 = m._Marker_key
and r._Category_key = 1004
and r._Relationship_key = p1._Relationship_key
and p1._PropertyName_key = 12948290
and p1.value = o.commonname
and p1.value = 'Not Specified'
and r._Relationship_key = p2._Relationship_key
and p2._PropertyName_key = 12948291
and not exists (select 1 from MRK_Marker m where o._Organism_key = m._Organism_key and p2.value = m.symbol)
order by p1.value, p2.value, m.symbol
''', 'auto')

addMarkerSQL = ""
for r in results:
        print(r)
        addMarkerSQL += '''insert into mrk_marker values(nextval('mrk_marker_seq'),%s,1,1,'%s','%s','UN',null,null,1098,1098,now(),now());\n''' \
                % (r['_organism_key'], r['nssymbol'], r['nssymbol'])

#print(addMarkerSQL)
db.sql(addMarkerSQL, None)
db.commit()
db.useOneConnection(0)

