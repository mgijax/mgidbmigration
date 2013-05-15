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
	select g1.* from gxd_assaynote g1
	where g1.assaynote like '%MGI:%'
	and not exists (select 1 from gxd_assaynote g2
		where g1._assay_key = g2._assay_key
		and g2.sequencenum != 1)
	order by g1._assay_key, g1.sequencenum
	''', 'auto')

for r in results:
    assayNote = r['assaynote']
    startMGI = assayNote.find('MGI:')
    endMGI = assayNote.find(' ', startMGI)
    newNote = assayNote[:startMGI] + '\Acc(' + assayNote[startMGI, endMGI] + ')' + assayNote[endMGI:]
    print assayNote
    print newNote
    print '------------'


db.useOneConnection(0)

