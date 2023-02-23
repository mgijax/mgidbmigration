#
# add Driver Components from Sue's spreadsheet
#
 
import sys 
import os
import db

db.setTrace()

driverComponents = {
        '1':['MGI:3057163', 'MGI:96609', 'J:93488', '', 0],
        '2':['MGI:2158467', 'HGNC:990', 'J:38288', '', 0],
        '3':['MGI:6492209', 'RGD:1564245', 'J:293568', '', 0],
        '4':['MGI:7339261', 'MGI:97255', 'J:229811', '', 0],
        '5':['MGI:7339257', 'MGI:97255', 'J:229811', '', 0],
        '6':['MGI:4819866', '', 'J:99626', 'tetO', 76],
        '7':['MGI:6197565', '', 'J:248533', 'CMV', 150],
        '8':['MGI:5308012', '', 'J:180282', 'ED-L2', 151],
        '9':['MGI:5544911', '944566', 'J:81098', 'HBVX', 152],
        '10':['MGI:5313507', '', 'J:181433', 'CRYBB1', 63],
        '11':['MGI:3716165', '', 'J:122914', 'AMELX', 11],
}
#        '12':['MGI:5476534', '', 'J:195112', 'mix1.L', 86],

addSQL = ""
addSQL += '''insert into mrk_marker values(nextval('mrk_marker_seq'),76,1,1,'tetO','tetO','UN',null,null,1098,1098,now(),now());\n'''
addSQL += '''insert into mrk_marker values(nextval('mrk_marker_seq'),150,1,1,'CMV','CMV','UN',null,null,1098,1098,now(),now());\n'''
addSQL += '''insert into mrk_marker values(nextval('mrk_marker_seq'),151,1,1,'ED-L2','ED-L2','UN',null,null,1098,1098,now(),now());\n'''
addSQL += '''insert into mrk_marker values(nextval('mrk_marker_seq'),152,1,1,'HBVX','HBVX','UN',null,null,1098,1098,now(),now());\n'''
#print(addSQL)
db.sql(addSQL, None)
db.commit()

results = db.sql('select max(_Accession_key) + 1 as maxKey from ACC_Accession', 'auto')
accKey = results[0]['maxKey']
addSQL = ""
for r in driverComponents:
        if driverComponents[r][4] == 0:
                continue
        if driverComponents[r][1] == "":
                continue
        results = db.sql('''select _marker_key from MRK_Marker where _organism_key = %s and symbol = '%s' '''  \
                % (driverComponents[r][4],driverComponents[r][3]))
        markerKey = results[0]['_marker_key']
        print(markerKey)
        addSQL += '''insert into acc_accession values(%s,'%s',null,%s,55,%s,2,0,1,1098,1098,now(),now());\n''' \
                % (accKey, driverComponents[r][1], driverComponents[r][1], markerKey)
        accKey += 1
#print(addSQL)
db.sql(addSQL)
db.commit()

addSQL = ""
for r in driverComponents:
        results = db.sql('''select _object_key from ACC_Accession where accID = '%s' ''' % (driverComponents[r][0]))
        objectKey1 = results[0]['_object_key']

        if driverComponents[r][4] == 0:
                results = db.sql('''select _object_key from ACC_Accession where accID = '%s' ''' % (driverComponents[r][1]))
                objectKey2 = results[0]['_object_key']
        else:
                results = db.sql('''select _marker_key from MRK_Marker where _organism_key = %s and symbol = '%s' ''' 
                        % (driverComponents[r][4],driverComponents[r][3]))
                objectKey2 = results[0]['_marker_key']

        results = db.sql('''select _object_key from ACC_Accession where accID = '%s' ''' % (driverComponents[r][2]))
        refsKey = results[0]['_object_key']
        addSQL += '''
                insert into MGI_Relationship values(nextval('mgi_relationship_seq'),1006,%s,%s,111172001,11391898,11451744,%s,1098,1098,now(),now());\n
                ''' % (objectKey1, objectKey2, refsKey)

#print(addSQL)
db.sql(addSQL, None)
db.commit()

