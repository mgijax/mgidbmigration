#!/usr/local/bin/python

'''
#
# sto135:
#       assay note
#       specimen note
#
#       with "MGI:xxxx" change to "\Acc(MGI:xxxx)"

'''
 
import sys 
import os
import re
import db

#
# Main
#

user = os.environ['MGD_DBUSER']
passwordFileName = os.environ['MGD_DBPASSWORDFILE']
db.set_sqlUser(user)
db.set_sqlPasswordFromFile(passwordFileName)

db.useOneConnection(1)

#results = db.sql('''
#	select a.accID, g1.* 
#	from acc_accession a, gxd_assaynote g1
#	where g1.assaynote like '%MGI:%'
#	and exists (select 1 from gxd_assaynote g2
#		where g1._assay_key = g2._assay_key
#		and g2.sequencenum != 1)
#	and g1._assay_key = a._object_key
#	and a._mgitype_key = 8
#	and a._logicaldb_key = 1
#	order by g1._assay_key, g1.sequencenum
#	''', 'auto')
#
#print 'assay notes that contain > 1 note chunk (> 255)'
#for r in results:
#    print r
#print '---------------'

print 'assay notes that have \Acc() added'
results = db.sql('''
	select a.accID, g1._assay_key, rtrim(g1.assayNote) as note 
	from acc_accession a, gxd_assaynote g1
	where g1.assaynote like '%MGI:%'
	and g1._assay_key = a._object_key
	and a._mgitype_key = 8
	and a._logicaldb_key = 1
	and not exists (select 1 from gxd_assaynote g2
		where g1._assay_key = g2._assay_key
		and g2.sequencenum != 1)
	''', 'auto')

for r in results:
    note = r['note']
    allIDs = re.findall('MGI:[0-9]*', note)
    for m in allIDs:
    	note = note.replace(m, '\Acc(' + m + ')')

    print r['accID']
    print r['note']
    note = note.replace('"', '\'')

    if len(note) > 255:
	print 'send to Connie'
    else:
    	updateSQL = '''update gxd_assaynote set assaynote = "%s" where _assay_key = %s''' % (note, r['_assay_key'])
	print updateSQL
	db.sql(updateSQL, None)

    print '---------------'

print 'specimen notes that have \Acc() added'
results = db.sql('''
	select a.accID, g1._specimen_key, rtrim(g1.specimenNote) as note 
	from acc_accession a, gxd_specimen g1
	where g1.specimennote like '%MGI:%'
	and g1._assay_key = a._object_key
	and a._mgitype_key = 8
	and a._logicaldb_key = 1
	order by g1._assay_key, g1.sequencenum
	''', 'auto')

for r in results:
    note = r['note']
    allIDs = re.findall('MGI:[0-9]*', note)
    for m in allIDs:
    	note = note.replace(m, '\Acc(' + m + ')')

    print r['accID']
    print r['note']
    note = note.replace('"', '\"')

    if len(note) > 255:
	print 'send to Connie'
    else:
    	updateSQL = '''update gxd_specimen set specimennote = "%s" where _specimen_key = %s''' % (note, r['_specimen_key'])
	print updateSQL
	db.sql(updateSQL, None)

    print '---------------'

db.useOneConnection(0)

