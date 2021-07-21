'''
#
# expt_delete_notes.py
#
#       See http://bhmgiwk01lp.jax.org/mediawiki/index.php/sw:Gxdhtload#Production_AE.2FGEO_experiment_migration
#
# Usage:
#       expt_delete_notes.py
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

TAB = '\t'
CRT = '\n'

outFile = '%s/mgidbmigration/yaks/expt_notes_save.txt' % os.getenv('DBUTILS')
print(outFile)

fpOut = open(outFile, 'w')

# the set of experiments to delete
# curation state 'Not Applicable' or 'Not Done'
# evaluation state 'Not Evaluated' or 'No'
db.sql('''select h.*
    into temporary table del
    from gxd_htexperiment h
    where h._curationstate_key in (20475420, 20475422)
    or h._evaluationstate_key in (20225941, 20225943)''', None)

db.sql('''create index idx1 on del(_experiment_key)''', None)

# get the accession id for the set to delete
db.sql('''select a.accid, d.*
    into temporary table toDelete
    from del d, acc_accession a
    where a._mgitype_key = 42
    and a._logicaldb_key = 190 -- GEO
    and a._object_key = d._experiment_key''', None)

db.sql('''create index idx2 on toDelete(_experiment_key)''', None)

# get notes from those we will delete
results = db.sql('''select d._experiment_key, d.accid, d.name, v1.term as evaluationState, v2.term as curationState, nc.note
    from mgi_note n, mgi_notechunk nc, toDelete d, gxd_htexperiment e, voc_term v1, voc_term v2
    where n._notetype_key = 1047
    and n._note_key = nc._note_key
    and d._experiment_key = n._object_key
    and  n._object_key = e._experiment_key
    and e._evaluationstate_key = v1._term_key
    and e._curationstate_key = v2._term_key
    order by e._experiment_key''', 'auto')

# _experiment_key       accid   name    evaluationstate curationstate   note
for r in results:
    fpOut.write('%s%s%s%s%s%s%s%s%s%s%s%s' % (r['_experiment_key'], TAB, r['accid'], TAB, r['name'], TAB, r['evaluationState'], TAB, r['curationState'], TAB, r['note'], CRT))

fpOut.close()
