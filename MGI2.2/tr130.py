#!/usr/local/bin/python

'''
#
# tr130.py 03/09/99
#
# Usage:
#       tr130.py
#
# TR 130
#
# Retrieve the Sequence IDs for Segments which contain one and only one
# encoding gene for loading into the Marker Sequence data set.
#
# Retrieve the SWISS-PROT IDs for Markers and attach the S-P Reference
# (ACC_AccessionReference).
#
# Create BCP files for loading into ACC_Accession and
# ACC_AccessionReference tables.
#
#
'''
 
import sys 
import string
import accessionlib
import mgdlib

CRT = '\n'
DL = '|'
DATES = mgdlib.date('%m/%d/%Y') + DL + mgdlib.date('%m/%d/%Y') + DL + CRT

def parseSeqAcc(tuple):
	global accKey
	global prevAccID
	global prevObject

	#
	# Assign unique accKeys for every Marker/Acc ID pair
	# Attach references to same accKey for same Marker/Acc ID
	#

	if prevAccID != tuple['accID'] or prevObject != tuple['_Marker_key']:

		accKey = accKey + 1
	
		accBCP.write(str(accKey) + DL +
		     	tuple['accID'] + DL +
		     	mgdlib.prvalue(tuple['prefixPart']) + DL +
		     	mgdlib.prvalue(tuple['numericPart']) + DL +
		     	str(tuple['_LogicalDB_key']) + DL +
		     	str(tuple['_Marker_key']) + DL +
		     	"2" + DL +
		     	str(tuple['private']) + DL +
		     	str(tuple['preferred']) + DL +
		     	DATES)

		prevAccID = tuple['accID']
		prevObject = tuple['_Marker_key']

	refBCP.write(str(accKey) + DL +
		     str(tuple['_Refs_key']) + DL +
		     DATES)

def processSeqID():
	global accKey
	global prevAccID
	global prevObject

	# Retrieve the next Accession key

	results = mgdlib.sql('select max(_Accession_key) from ACC_Accession', 'auto')
	accKey = results[0]['']

	prevAccID = ''
	prevObject = ''

	cmds = []
	parsers = []

	#
	# Select all Probes of Source 'mouse, laboratory' which contain
	# at least one encoding gene
	#

	cmds.append('select distinct p._Probe_key, p.name, pm._Marker_key, m.symbol ' +
            	'into tempdb..probes1 ' +
            	'from PRB_Probe p, PRB_Source s, PRB_Marker pm, MRK_Marker m ' +
            	'where p._Source_key = s._Source_key ' +
            	'and s.species = "mouse, laboratory" ' +
            	'and p._Probe_key = pm._Probe_key ' +
            	'and pm.relationship = "E" ' + 
		'and pm._Marker_key = m._Marker_key')

	cmds.append('create nonclustered index pk on tempdb..probes1(_Probe_key)')
	parsers.append(None)
	parsers.append(None)
	mgdlib.sql(cmds, parsers)
	print "Done - probes1"

	cmds = []
	parsers = []

	#
	# Select all Probes with one and only one encoding Marker
	#

	cmds.append('select * into tempdb..probes2 from tempdb..probes1 group by _Probe_key having count(*) = 1')
	cmds.append('create nonclustered index pk on tempdb..probes2(_Probe_key)')
	parsers.append(None)
	parsers.append(None)
	mgdlib.sql(cmds, parsers)
	print "Done - probes2"

	#
	# Retrieve unique Sequence Accession ID/Reference (J:) pairs
	# for each Marker by using its associated Probe
	#

	cmds = []
	parsers = []
	cmds.append('select distinct p.symbol, p._Marker_key, ' +
	    	'a.accID, a.prefixPart, a.numericPart, a._LogicalDB_key, a._MGIType_key, ' +
	    	'a.private, a.preferred, ar._Refs_key ' +
            	'from tempdb..probes2 p, ACC_Accession a, ACC_AccessionReference ar ' +
            	'where p._Probe_key = a._Object_key ' +
            	'and a._MGIType_key = 3 ' +
            	'and a._LogicalDB_key = 9 ' +
            	'and a._Accession_key = ar._Accession_key ' +
		'order by p._Marker_key, a.accID')
	parsers.append(parseSeqAcc)
	mgdlib.sql(cmds, parsers)

	cmds = []
	parsers = []
	cmds.append('drop table tempdb..probes1')
	cmds.append('drop table tempdb..probes2')
	parsers.append(None)
	parsers.append(None)
	mgdlib.sql(cmds, parsers)

def processSWISSPROT():

	#
	# Select all Marker/SWISS-PROT Accession keys
	#

	refKey = accessionlib.get_Object_key('J:53168', 'Reference')

	if refKey is not None:
		cmd = 'select _Accession_key from ACC_Accession ' + \
              	      'where _MGIType_key = 2 and _LogicalDB_key = 13'

		results = mgdlib.sql(cmd, 'auto')

		for r in results:
			refBCP.write(str(r['_Accession_key']) + DL +
		     		str(refKey) + DL +
		     		DATES)
		
#
# Main
#

mgdlib.set_sqlUser('mgd_dbo')
mgdlib.set_sqlPassword(string.strip(open('/opt/sybase/admin/.mgd_dbo_password', 'r').readline()))

accBCP = open('ACC_Accession.bcp', 'w')
refBCP = open('ACC_AccessionReference.bcp', 'w')
processSeqID()
processSWISSPROT()
accBCP.close()
refBCP.close()

