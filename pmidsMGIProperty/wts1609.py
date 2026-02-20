 
import sys 
import os
import db
import loadlib

#db.setTrace()

loadDate = loadlib.loaddate

# _property_key, _object_key, value, sequenceNum
propertyBCP = "%s|1002|20475430|%s|42|%s|%s|1064|1064|%s|%s\n"

outFile = open('MGI_Property.bcp', 'w')

results = db.sql(''' select nextval('mgi_property_seq') as maxKey ''', 'auto')
nextPropKey  = results[0]['maxKey']

inFile = open('PMID_to_add.txt', 'r')
for line in inFile.readlines():
    tokens = line[:-1].split('\t')
    accid = tokens[0]
    pubmedid = tokens[1]
    results = db.sql(''' select * from acc_accession where accid = '%s' ''' % (accid), 'auto')

    if len(results) == 0:
        print(tokens)
        continue

    objectKey = results[0]['_object_key']

    results = db.sql('''
        select max(sequenceNum) + 1 as nextNum
        from MGI_Property p
        where p._Object_key = %s
        and p._PropertyTerm_key = 20475430
        and p._PropertyType_key = 1002
        and p.value = '%s'
        ''' % (objectKey, pubmedid), 'auto')
    if len(results) == 0:
        # already exists; skip it
        continue

    results = db.sql('''
        select max(sequenceNum) + 1 as nextNum
        from MGI_Property p
        where p._Object_key = %s
        and p._PropertyTerm_key = 20475430
        and p._PropertyType_key = 1002
        ''' % (objectKey), 'auto')
    if results[0]['nextNum'] == None:
        sequenceNum = 1
    else:
        sequenceNum = results[0]['nextNum']

    outFile.write(propertyBCP % (nextPropKey, objectKey, pubmedid, sequenceNum, loadDate, loadDate))
    nextPropKey += 1

inFile.close()
outFile.close()

