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
import reportlib

#
# Main
#

user = os.environ['MGD_DBUSER']
passwordFileName = os.environ['MGD_DBPASSWORDFILE']
db.set_sqlUser(user)
db.set_sqlPasswordFromFile(passwordFileName)

db.useOneConnection(1)

#results = db.sql('''
#	select g1.* from gxd_assaynote g1
#	where g1.assaynote like '%MGI:%'
#	and exists (select 1 from gxd_assaynote g2
#		where g1._assay_key = g2._assay_key
#		and g2.sequencenum != 1)
#	order by g1._assay_key, g1.sequencenum
#	''', 'auto')
#
#print 'assay notes that contain > 1 note chunk (> 255)'
#for r in results:
#    print r

print 'assay notes that have \Acc() added'
results = db.sql('''
	select g1._assay_key, rtrim(g1.assayNote) as assayNote 
	from gxd_assaynote g1
	where g1.assaynote like '%MGI:%'
	and not exists (select 1 from gxd_assaynote g2
		where g1._assay_key = g2._assay_key
		and g2.sequencenum != 1)
	order by g1._assay_key, g1.sequencenum
	''', 'auto')

for r in results:
    assayNote = r['assayNote']

    newNote = assayNote
    allIDs = re.findall('MGI:[0-9]*', assayNote)
    for m in allIDs:
    	newNote = newNote.replace(m, '\Acc(' + m + ')')

    if len(newNote) > 255:
	print 'the new note is too long...send to Connie'
    else:
    	updateSQL = '''
		update gxd_assaynote set assaynote = '%s' where _assay_key = %s
		''' % (newNote, r['_assay_key'])
	print updateSQL

    print '---------------'

db.useOneConnection(0)

