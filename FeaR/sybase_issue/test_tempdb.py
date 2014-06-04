#!/usr/local/bin/python
#
# test_tempdb.py 
###########################################################################
import db
import os
import sys

TAB = '\t'

passwordFile = os.environ['MGI_PUBPASSWORDFILE']
user = os.environ['MGI_PUBLICUSER']

db.set_sqlUser(user)
db.set_sqlPasswordFromFile(passwordFile)

idTempTable = 'MGI_ID'
idBcpFile = 'mgi_id.bcp'
#
# Load the temp tables with the input data.
#
print 'Load the relationship data into the temp table: %s' % idTempTable
sys.stdout.flush()
bcpCmd = 'cat %s | bcp tempdb..%s in %s -c -t"%s" -S%s -U%s' % (passwordFile, idTempTable, idBcpFile, TAB, db.get_sqlServer(), db.get_sqlUser())
rc = os.system(bcpCmd)
if rc <> 0:
    closeFiles()
    sys.exit(1)

db.sql('''create index idx1 on tempdb..%s (mgiID1)''' % idTempTable, None)
db.sql('''create index idx2 on tempdb..%s (mgiID1TypeKey)'''  % idTempTable, None)
db.sql('''create index idx3 on tempdb..%s (mgiID2)''' % idTempTable, None)
db.sql('''create index idx4 on tempdb..%s (mgiID2TypeKey)''' % idTempTable, None)


