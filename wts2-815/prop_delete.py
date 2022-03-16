'''
#
# prop_delete.py
#
# Usage:
#       prop_delete.py
#
# History:
#
# sc   03/16/2022
#       - created WTS2-431
#
'''
import os
import sys
import db

TAB = '\t'
CRT = '\n'

db.useOneConnection(1)

# the set of duplicated properties
db.sql('''select a.accid, p.value, e._experiment_key
    into temporary table dupes
        from GXD_HTExperiment e, ACC_Accession a, MGI_Property p
        where e._Experiment_key = a._Object_key
        and a._MGIType_key = 42
        and a._LogicalDB_key = 190
        --and a.preferred = 0
        and e._Experiment_key = p._Object_key
        and p._PropertyTerm_key = 20475430
        and p._PropertyType_key = 1002
    group by a.accid, p.value, e._experiment_key 
    having count(*) > 1''', None)

db.sql('''create index idx1 on dupes(_experiment_key)''', None)

# pull in the property key
results = db.sql('''select d.*, p._property_key
    from dupes d, mgi_property p
    where d._experiment_key = p._object_key
    and p._PropertyTerm_key = 20475430
    and p._PropertyType_key = 1002
    order by _experiment_key, _property_key''', 'auto')

pubmedDupeDict = {}
for r in results:
    geoID = r['accid']
    propertyKey = r['_property_key']
    if geoID not in pubmedDupeDict:
        pubmedDupeDict[geoID] = []
    pubmedDupeDict[geoID].append(propertyKey)

# keep the last one in the list
for geoID in pubmedDupeDict:
    print('geoID: %s ' % geoID)
    pubMedList = pubmedDupeDict[geoID]
    print ('pubMedList: %s' % pubMedList)
    for i in range(len(pubMedList)-1):
        print('i: %s' % i)
        propertyKey = pubMedList[i]
        print('propertyKey: %s' % propertyKey)
        print('''delete from MGI_Property where _Property_key = %s''' % propertyKey)
        db.sql('''delete from MGI_Property where _Property_key = %s''' % propertyKey, None)
db.commit()

results = db.sql('''select a.accid, p.value, e._experiment_key, count(a.accid) as totalCt
            from GXD_HTExperiment e, ACC_Accession a, MGI_Property p
            where e._Experiment_key = a._Object_key
            and a._MGIType_key = 42
            and a._LogicalDB_key = 190
            --and a.preferred = 0
            and e._Experiment_key = p._Object_key
            and p._PropertyTerm_key = 20475430
            and p._PropertyType_key = 1002
    group by a.accid, p.value, e._experiment_key 
    having count(*) > 1''', 'auto')

print('database check: %s' % len(results))
for r in results:
    print('%s%s%s%s%s%s%s' % (r['accid'], TAB, r['value'], TAB, r['_experiment_key'], TAB, r['totalCt'])) 

db.useOneConnection(0)
