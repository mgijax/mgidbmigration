#
# add property/Not Specified markers to MGI
# add property/other markers with NCBI ids to MGI
#
 
import sys 
import os
import db

db.setTrace()

# non-mouse markers where organism = 'Not Specified'
results = db.sql('''
select distinct m._Marker_key, m.symbol as msymbol, p1.value, p2.value as nssymbol, o._organism_key, o.commonname
from MRK_Marker m, MGI_Relationship r,
MGI_Relationship_Property p1, MGI_Organism o,
MGI_Relationship_Property p2
where r._Object_key_2 = m._Marker_key
and r._Category_key = 1004
and r._Relationship_key = p1._Relationship_key
and p1._PropertyName_key = 12948290
and lower(p1.value) = lower(o.commonname)

-- property/organism = Not Specified
and p1.value = 'Not Specified'

-- property/gene symbol does not exist in MRK_Marker
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

if len(results) > 0:
        #print(addMarkerSQL)
        db.sql(addMarkerSQL, None)
        db.commit()

# non-mouse markers where organism != 'Not Specified' && property conatins NCBI id
results = db.sql(''' select nextval('mrk_marker_seq') as maxKey ''', 'auto')
markerKey = results[0]['maxKey']
results = db.sql('select max(_Accession_key) + 1 as maxKey from ACC_Accession', 'auto')
accKey = results[0]['maxKey']

results = db.sql('''
select distinct m._Marker_key, m.symbol as msymbol, p1.value, p2.value as nssymbol, p3.value as accid, o._organism_key, o.commonname
from MRK_Marker m, MGI_Relationship r,
MGI_Relationship_Property p1, MGI_Organism o,
MGI_Relationship_Property p2, MGI_Relationship_Property p3
where r._Object_key_2 = m._Marker_key
and r._Category_key = 1004

-- property/organism != Not Specified
and r._Relationship_key = p1._Relationship_key
and p1._PropertyName_key = 12948290
and p1.value = o.commonname
and p1.value != 'Not Specified'

-- property/gene symbol does not exist in MRK_Marker
and r._Relationship_key = p2._Relationship_key
and p2._PropertyName_key = 12948291
and not exists (select 1 from MRK_Marker m where o._Organism_key = m._Organism_key and p2.value = m.symbol)

-- property contains NCBI id
and r._relationship_key = p3._relationship_key
and p3._propertyName_key = 12948292

order by p1.value, p2.value, m.symbol

''', 'auto')

addMarkerSQL = ""
for r in results:
        print(r)
        addMarkerSQL += '''insert into mrk_marker values(%s,%s,1,1,'%s','%s','UN',null,null,1098,1098,now(),now());\n''' \
                % (markerKey, r['_organism_key'], r['nssymbol'], r['nssymbol'])
        addMarkerSQL += '''insert into acc_accession values(%s,'%s',null,%s,55,%s,2,0,1,1098,1098,now(),now());\n''' \
                % (accKey, r['accid'], r['accid'], markerKey)
        markerKey += 1
        accKey += 1

if len(results) > 0:
        print(addMarkerSQL)
        db.sql(addMarkerSQL, None)
        db.commit()
        # update mrk_marker_seq auto-sequence
        db.sql(''' select setval('mrk_marker_seq', (select max(_Marker_key) from MRK_Marker)) ''', None)
        db.commit()

