'''
#
# expt_add_notes.py
#
#       See http://bhmgiwk01lp.jax.org/mediawiki/index.php/sw:Gxdhtload#Production_AE.2FGEO_experiment_migration
#
# Usage:
#       expt_add_notes.py
#
# History:
#
# sc   07/21/2010
#       - created WTS2-431
#
'''
import os
import sys
import db
import loadlib

TAB = '\t'
CRT = '\n'
NOTE_TYPE_KEY = 1047    # GXD HT Experiment Note
MGI_TYPE_KEY = 42       # GXD_HT_Experiment
CREATED_BY = 1001       # note creator - same as currently in db
SEQUENCE_NUM = 1

# the next note key to use in the db
nextNoteKey = db.sql('''select max(_note_key) + 1 as maxKey from mgi_note ''', 'auto')[0]['maxKey']

# today's date
loadDate = loadlib.loaddate

bcpCommand = os.environ['PG_DBUTILS'] + '/bin/bcpin.csh'
currentDir = os.getcwd()
# {geoID:exptKey, ...}
exptLookup = {}

inFile = '%s/mgidbmigration/yaks/expt_notes_save.txt' % os.getenv('DBUTILS')
print(inFile)
#noteBcp = '%s/mgidbmigration/yaks/mgi_note.bcp' % os.getenv('DBUTILS')
#chunkBcp = '%s/mgidbmigration/yaks/mgi_notechunk.bcp' % os.getenv('DBUTILS')
noteBcp = 'mgi_note.bcp'
chunkBcp = 'mgi_notechunk.bcp'

bcpCommand = os.getenv('PG_DBUTILS') + '/bin/bcpin.csh'

# _experiment_key       accid   name    evaluationstate curationstate   note
fpIn = open(inFile, 'r')
fpNote = open(noteBcp, 'w')
fpChunk = open(chunkBcp, 'w')

# get notes from those we will delete
results = db.sql('''select e._experiment_key, a.accid, e.name
    from gxd_htexperiment e, acc_accession a
    where e._experiment_key = a._object_key
    and a._mgitype_key = 42
    and a._logicaldb_key = 190 -- GEO
    order by e._experiment_key''', 'auto')

for r in results:
    exptKey = r['_experiment_key']
    geoID = r['accid']
    exptLookup[geoID] = exptKey

# Read through the saved experiment note file and create bcp file
for line in fpIn.readlines():
    tokens = str.split(line, TAB)
    geoID = tokens[1]
    note = str.strip(tokens[5])
    if geoID in exptLookup:
        exptKey = exptLookup[geoID]
        #print('Found experiment for %s' % geoID)
        fpNote.write("%s|%s|%s|%s|%s|%s|%s|%s%s" % (nextNoteKey, exptKey, MGI_TYPE_KEY, NOTE_TYPE_KEY, CREATED_BY, CREATED_BY, loadDate, loadDate, CRT))
        fpChunk.write("%s|%s|%s|%s|%s|%s|%s%s" % (nextNoteKey, SEQUENCE_NUM, note, CREATED_BY, CREATED_BY, loadDate, loadDate, CRT))

        nextNoteKey += 1
    else:
        print('No experiment in database for %s' % geoID)

# bcp notes
noteCmd = '%s %s %s %s %s %s "|" "\\n" mgd' % \
        (bcpCommand, db.get_sqlServer(), db.get_sqlDatabase(), 'MGI_Note', currentDir, noteBcp)

chunkCmd = '%s %s %s %s %s %s "|" "\\n" mgd' % \
        (bcpCommand, db.get_sqlServer(), db.get_sqlDatabase(), 'MGI_NoteChunk', currentDir, chunkBcp)

print(noteCmd)
print(chunkCmd)

os.system(noteCmd)
os.system(chunkCmd)

fpIn.close()
fpNote.close()
fpChunk.close()
