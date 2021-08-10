'''
#
# expt_add_notes_accessions.py
#
#       See http://bhmgiwk01lp.jax.org/mediawiki/index.php/sw:Gxdhtload#Production_AE.2FGEO_experiment_migration
#
# Usage:
#       expt_add_notes_accessions.py
#
# History:
#
# sc 08/05/2021 - updated to add back AE ID as secondary
# 
# sc   7/2021 
#       - created GXD HT GEO epic
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
CREATED_BY = 1001       # note creator 
SEQUENCE_NUM = 1
AE_LDB_KEY = 189

preferred = 0
private = 0

# experiment updates
evalState = 20225943
curState = 20475420
evalBy = 1064
table = 'GXD_HTExperiment'

# the next note key to use in the db
nextNoteKey = db.sql('''select max(_note_key) + 1 as maxKey from mgi_note ''', 'auto')[0]['maxKey']

# the next accession key to use in the db
nextAccKey = db.sql('''select max(_accession_key) + 1 as maxKey from acc_accession ''', 'auto')[0]['maxKey']

# today's date
loadDate = loadlib.loaddate

bcpCommand = os.environ['PG_DBUTILS'] + '/bin/bcpin.csh'
currentDir = os.getcwd()
# {geoID:exptKey, ...}
exptLookup = {}

inFileNotes = '%s/mgidbmigration/yaks/expt_notes_save.txt' % os.getenv('DBUTILS')
print(inFileNotes)

inFileAccession = '%s/mgidbmigration/yaks/accessions_save.txt' % os.getenv('DBUTILS')
print(inFileAccession)

#noteBcp = '%s/mgidbmigration/yaks/mgi_note.bcp' % os.getenv('DBUTILS')
#chunkBcp = '%s/mgidbmigration/yaks/mgi_notechunk.bcp' % os.getenv('DBUTILS')
noteBcp = 'mgi_note.bcp'
chunkBcp = 'mgi_notechunk.bcp'
accessionBcp = 'acc_accession.bcp'
bcpCommand = os.getenv('PG_DBUTILS') + '/bin/bcpin.csh'

# _experiment_key       accid   name    evaluationstate curationstate   note
fpNotesIn = open(inFileNotes, 'r')
fpAccessionIn = open(inFileAccession, 'r')
fpNote = open(noteBcp, 'w')
fpChunk = open(chunkBcp, 'w')
fpAccession = open(accessionBcp, 'w')
sqlFile = open(table + '.sql', 'w')

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
for line in fpNotesIn.readlines():
    tokens = str.split(line, TAB)
    geoID = tokens[1]
    note = str.strip(tokens[5])
    if geoID in exptLookup:
        exptKey = exptLookup[geoID]
        #print('Found experiment for %s' % geoID)

        fpNote.write("%s|%s|%s|%s|%s|%s|%s|%s%s" % (nextNoteKey, exptKey, MGI_TYPE_KEY, NOTE_TYPE_KEY, CREATED_BY, CREATED_BY, loadDate, loadDate, CRT))

        fpChunk.write("%s|%s|%s|%s|%s|%s|%s%s" % (nextNoteKey, SEQUENCE_NUM, note, CREATED_BY, CREATED_BY, loadDate, loadDate, CRT))

        updateSQL = '''update %s set _evaluationstate_key = %s, 
            _curationstate_key = %s, _evaluatedby_key = %s, evaluated_date = '%s'
            where _experiment_key = %s;''' % \
                (table, evalState, curState, evalBy, loadDate, exptKey)
        sqlFile.write(updateSQL + "\n")
        nextNoteKey += 1
    else:
        print('Notes: No experiment in database for %s' % geoID)

for line in fpAccessionIn.readlines():
    geoID = str.strip(line)
    numericPart = geoID[3:]
    prefixPart = 'E-GEOD-'
    aeID = '%s%s' % (prefixPart, numericPart)
    print('geoID: %s aeID: %s' % (geoID, aeID))
    if geoID in exptLookup:
        exptKey = exptLookup[geoID]
        print('Found experiment for %s' % geoID)

        fpAccession.write('%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s%s' % (nextAccKey, aeID, prefixPart, numericPart, AE_LDB_KEY, exptKey, MGI_TYPE_KEY, private, preferred, CREATED_BY, CREATED_BY, loadDate, loadDate, CRT ))
        nextAccKey += 1
    else:
        print('Accession: No experiment in database for %s' % geoID)

# bcp notes
noteCmd = '%s %s %s %s %s %s "|" "\\n" mgd' % \
        (bcpCommand, db.get_sqlServer(), db.get_sqlDatabase(), 'MGI_Note', currentDir, noteBcp)

chunkCmd = '%s %s %s %s %s %s "|" "\\n" mgd' % \
        (bcpCommand, db.get_sqlServer(), db.get_sqlDatabase(), 'MGI_NoteChunk', currentDir, chunkBcp)

accessionCmd = '%s %s %s %s %s %s "|" "\\n" mgd' % \
        (bcpCommand, db.get_sqlServer(), db.get_sqlDatabase(), 'ACC_Accession', currentDir, accessionBcp)

print(noteCmd)
print(chunkCmd)
print(accessionCmd)

fpNotesIn.close()
fpAccessionIn.close()
fpNote.close()
fpChunk.close()
fpAccession.close()
sqlFile.close()

os.system(noteCmd)
os.system(chunkCmd)
os.system(accessionCmd)

