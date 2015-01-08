#!/usr/local/bin/python

import sys
import os
import string
import db
import reportlib
import stats
import time

startTime = time.time()

def report (s):
	print 'updateStats.py : %8.3f sec : %s' % (time.time() - startTime, s)
	return

#
#  Set up a connection to the mgd database.
#
dbServer = os.environ['MGD_DBSERVER']
dbName = os.environ['MGD_DBNAME']
user = os.environ['MGD_DBUSER']
passwordFileName = os.environ['MGD_DBPASSWORDFILE']
db.useOneConnection(1)
db.set_sqlUser(user)
db.set_sqlPasswordFromFile(passwordFileName)
stats.setSqlFunction(db.sql)

report('Set up database connection')

# now compute new measurements to ensure that the new statistics have one.
stats.measureAllHavingSql()
report ('Computed new measurements')

db.useOneConnection(0)

report ('Finished')
