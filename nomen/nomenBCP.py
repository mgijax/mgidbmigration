#!/usr/local/bin/python

'''
#
# nomenBCP.py 03/08/99
#
# Usage:
#       nomenBCP.py
#
# Nomen
#
# Create BCP files for loading into 
# MRK_Nomen
# MRK_Nomen_Other
# MRK_Nomen_Reference
#
#
'''
 
import sys 
import string
import regsub
import accessionlib
import mgdlib

CRT = '\n'
DL = '\t'

def addReference(jnumList):
	global refAdded

	for j in jnumList:
		j = regsub.gsub('J', '', j)
		j = regsub.gsub(':', '', j)
		refKey = accessionlib.get_Object_key('J:' + j, 'Reference')

		if refKey is not None:
			refBCP.write(str(nomenKey) + DL + \
		             	str(refKey) + DL + \
		             	'0' + DL + \
		             	mgdlib.date('%m/%d/%Y') + DL + \
		             	mgdlib.date('%m/%d/%Y') + CRT)
			refAdded = 1

# Main
#

mgdlib.set_sqlUser('mgd_dbo')
mgdlib.set_sqlPassword(string.strip(open('/home/lec/.mgd_dbo_password', 'r').readline()))

processOther = 1
processRef = 1
processHomRef = 1

nomenBCP = open('MRK_Nomen.bcp', 'w')
noteBCP = open('MRK_Nomen_Notes.bcp', 'w')

if processOther:	
	otherBCP = open('MRK_Nomen_Other.bcp', 'w')

if processRef or processHomRef:
	refBCP = open('MRK_Nomen_Reference.bcp', 'w')

nomenKey = 1000
otherKey = 1000
suidKey = 90
homRefKey = accessionlib.get_Object_key('J:25000', 'Reference')

cmd = 'select ' + \
      'proposedSymbol, proposedName, approvedSymbol, markerName, chromosome, humanSymbol, ' + \
      'ECnumber, ' + \
      'approvDate = convert(varchar(8), approvDate, 1), ' + \
      'submitDate = convert(varchar(8), submitDate, 1), ' + \
      'markerType, nomenType, status, authorSays, ' + \
      'otherNames, jnum, citation, note ' + \
      'from tempdb..NomenAll'

results = mgdlib.sql(cmd, 'auto')

for r in results:

	markerTypeKey = 1
	eventKey = -1
	statusKey = -1
 
        # Marker Type
	if r['markerType'] == 'G':
		markerTypeKey = 1
	elif r['markerType'] == 'D':
		markerTypeKey = 2
	elif r['markerType'] == 'Q':
		markerTypeKey = 6
	elif r['markerType'] == 'C':
		markerTypeKey = 3

	# Nomen Event Type
	# 1 = New, 2 = Withdrawal
	# Status Type
	# 2 = Deleted, 3 = Reserved
	# explicity set the Status Type for Deleted and Reserved symbols
 
	if r['nomenType'] == 'c':
		eventKey = 1
	elif r['nomenType'] == 'd':
		eventKey = 1
		statusKey = 2
	elif r['nomenType'] == 'n':
		eventKey = 1
	elif r['nomenType'] == 'p':
		eventKey = 1
	elif r['nomenType'] == 'r':
		eventKey = 1
		statusKey = 3
	elif r['nomenType'] == 'w':
		eventKey = 2
 
	# Status 
	# Status Type 
	# 1 = Pending, 2 = Deleted, 3 = Reserved, 4 = Approved, 5 = Broadcast 
	# leave the Status Type alone if it was assigned previously and has not 
	# been Broadcast 
	# leave the Status Type alone if it is a Delete 
 
	# PENDING and 09/09/99 --> Pending 
	# PENDING and !09/09/99 --> Broadcast 
	# APPROVED and 09/09/99  --> Pending 
	# APPROVED and !09/09/99 --> Broadcast 
	# NULL and 09/09/99      --> Pending 
	# NULL and !09/09/99     --> Broadcast 
	# PENDING and approvedSymbol not null --> Approved
 
	if statusKey == -1 and r['status'] == "PENDING" and r['approvDate'] == "09/09/99":
		statusKey = 1
	elif r['status'] == "PENDING" and r['approvDate'] != "09/09/99":
		statusKey = 5
	if statusKey == -1 and r['status'] == "APPROVED" and r['approvDate'] == "09/09/99":
		statusKey = 1
	elif statusKey != 2 and statusKey != 3 and r['status'] == "APPROVED" and r['approvDate'] != "09/09/99":
		statusKey = 5
	elif statusKey == -1 and r['status'] is None and r['approvDate'] == "09/09/99":
		statusKey = 1
	elif r['status'] is None and r['approvDate'] != "09/09/99":
		statusKey = 5
 
        if statusKey == -1 and r['status'] == "PENDING":
		statusKey = 4
 
        if r['chromosome'] == "RE" and statusKey != 2 and statusKey != 5:
		statusKey = 3
 
        if statusKey == 3 and r['approvDate'] != "09/09/99" and r['approvDate'] is not None:
		statusKey = 5
 
        if r['approvDate'] == "09/09/99":
		r['approvDate'] = ""
 
	note = r['note']

	if note is not None:
		seqNum = 1
		noteType = 'C'

		note = regsub.gsub('', '  ', note)
		note = regsub.gsub('"', '\'', note)
		note = regsub.gsub('Related Refs', 'Related Ref', note)
		note = regsub.gsub('Related Ref(s)', 'Related Ref', note)
		note = regsub.gsub('related ref', 'Related Ref', note)

		# Notes > 255 go into separate Note table
		if len(note) > 255:
			# insert into MRK_Nomen_Notes
			while len(note) > 0:
				noteSeg = note[:255]
				noteBCP.write(str(nomenKey) + DL + \
				      	str(seqNum) + DL + \
				      	noteSeg + DL + \
				      	noteType + DL + \
	       	       		      	mgdlib.date('%m/%d/%Y') + DL + \
	       	       		      	mgdlib.date('%m/%d/%Y') + CRT)
				seqNum = seqNum + 1
				note = note[255:]

			note = ''

		if processRef:
			refIdx = string.find(note, 'Related Ref:')

			if refIdx >= 0:
				refAdded = 0
				jnumStr = note[refIdx + 13:]

				jnumList = string.splitfields(jnumStr, '; ')
				addReference(jnumList)

				if not refAdded:
					jnumList = string.splitfields(jnumStr, ', ')
					addReference(jnumList)

				if not refAdded:
					jnumList = string.splitfields(jnumStr, ' & ')
					addReference(jnumList)

		if processHomRef and homRefKey is not None:

			# J:25000 homology assertion reference

			if string.find(note, 'J25000') >= 0 or \
			   string.find(note, 'J:25000') >= 0:
				refBCP.write(str(nomenKey) + DL + \
				           str(homRefKey) + DL + \
				           '0' + DL + \
				           mgdlib.date('%m/%d/%Y') + DL + \
				           mgdlib.date('%m/%d/%Y') + CRT)

	if len(r['proposedSymbol']) > 25:
		print "Pro Sym:  " + mgdlib.prvalue(r['proposedSymbol'])

	if r['proposedName'] is not None and len(r['proposedName']) > 255:
		print "Pro Name:  " + mgdlib.prvalue(r['proposedName'])

	if r['approvedSymbol'] is not None and len(r['approvedSymbol']) > 25:
		print "App Sym:  " + mgdlib.prvalue(r['approvedSymbol'])

	if r['markerName'] is not None and len(r['markerName']) > 255:
		print "App Name:  " + mgdlib.prvalue(r['markerName'])

	if len(r['chromosome']) > 8:
		print "Chr:  " + mgdlib.prvalue(r['chromosome'])

	if r['humanSymbol'] is not None and len(r['humanSymbol']) > 25:
		print "Human:  " + mgdlib.prvalue(r['humanSymbol'])
		r['humanSymbol'] = ''

	if r['ECnumber'] is not None and len(r['ECnumber']) > 25:
		print "EC:  " + mgdlib.prvalue(r['ECnumber'])

	nomenBCP.write(str(nomenKey) + DL + \
		       str(markerTypeKey) + DL + \
		       str(statusKey) + DL + \
		       str(eventKey) + DL + \
		       str(suidKey) + DL + \
		       mgdlib.prvalue(r['proposedSymbol']) + DL + \
		       mgdlib.prvalue(r['proposedName']) + DL + \
		       mgdlib.prvalue(r['approvedSymbol']) + DL + \
		       mgdlib.prvalue(r['markerName']) + DL + \
		       mgdlib.prvalue(r['chromosome']) + DL + \
		       mgdlib.prvalue(r['humanSymbol']) + DL + \
		       mgdlib.prvalue(r['ECnumber']) + DL + \
		       mgdlib.prvalue(note) + DL + \
		       mgdlib.prvalue(r['approvDate']) + DL + \
		       mgdlib.prvalue(r['submitDate']) + DL + \
		       mgdlib.date('%m/%d/%Y') + CRT)

	# Other Names
 
	if processOther:
		isAuthor = 1
		authorList = []

		if r['authorSays'] is not None and r['authorSays'] != r['otherNames']:
			authorList = string.splitfields(r['authorSays'], '; ')
			for a in authorList:
				otherBCP.write(str(otherKey) + DL + \
			       		str(nomenKey) + DL + \
			       		mgdlib.prvalue(a) + DL + \
			       		str(isAuthor) + DL + 
		       	       		mgdlib.date('%m/%d/%Y') + DL + \
		       	       		mgdlib.date('%m/%d/%Y') + CRT)
                		otherKey = otherKey + 1
				isAuthor = 0
 
        	if r['otherNames'] is not None:
			isAuthor = 0
			othersList = string.splitfields(r['otherNames'], '; ')
			for o in othersList:
				if o != r['authorSays'] and o not in authorList:
					otherBCP.write(str(otherKey) + DL + \
			       		       	str(nomenKey) + DL + \
			       		       	mgdlib.prvalue(o) + DL + \
			       			str(isAuthor) + DL + 
		       	       		       	mgdlib.date('%m/%d/%Y') + DL + \
		       	       		       	mgdlib.date('%m/%d/%Y') + CRT)
                			otherKey = otherKey + 1
 
	# References
 
	if processRef:
		primaryRef = 1

        	if r['jnum'] is not None:
			r['jnum'] = regsub.gsub('::', ':', r['jnum'])
			jnumList = string.splitfields(r['jnum'], ', ')
	
			for j in jnumList:
				refKey = accessionlib.get_Object_key(j, 'Reference')
	
				if refKey is not None:
					refBCP.write(str(nomenKey) + DL + \
				             	str(refKey) + DL + \
				             	str(primaryRef) + DL + \
				             	mgdlib.date('%m/%d/%Y') + DL + \
				             	mgdlib.date('%m/%d/%Y') + CRT)
					primaryRef = 0

	nomenKey = nomenKey + 1

nomenBCP.close()
noteBCP.close()

if processOther:
	otherBCP.close()

if processRef or processHomRef:
	refBCP.close()
