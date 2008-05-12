#!/usr/local/bin/python

# input: parses Janan's strain file
# outputs:
#	1. updates strain type field in database
#	2. produces association load file for Festing links
#	3. produces association load file for MPD links
#	4. for strains not in the input file:
#		a. sets "standard" strains to be non-standard
#		b. flags them with "Needs Review - load"


import sys
import db
import re
import time

USAGE = '''Usage: %s <server> <db> <user> <pwd file> <input file>
	<server> : database server name
	<db> : database name
	<user> : database username
	<pwd file> : file containing password for <user>
	<input file> : path to Janan's strain spreadsheet as tab-delimited
''' % sys.argv[0]

INVALID_COUNT = 0		# counts number of lines with warnings
ID_MAP = {}			# maps secondary strain IDs to primary IDs
START_TIME = time.time()	# time (in sec) at which script begins

def report (msg):
	elapsed = time.time() - START_TIME
	sys.stderr.write ('%7.3f %s\n' % (elapsed, msg))
	return

def bailout (msg, showUsage = True):
	if showUsage:
		report (USAGE)
	report (msg)
	sys.exit(1)

def processCommandLine ():
	if len(sys.argv) != 6:
		bailout ('Error: wrong number of arguments')
	
	try:
		fp = open (sys.argv[4], 'r')
		password = fp.readline().strip()
		fp.close()
	except:
		bailout ('Error: cannot read password from %s' % sys.argv[4])

	try:
		db.set_sqlLogin (sys.argv[3], password, sys.argv[1],
			sys.argv[2])
		db.sql ('select count(1) from MGI_dbInfo', 'auto')
	except:
		bailout ('Error: database login failed')

	return sys.argv[5]

def readFile (inputFilename):
	global INVALID_COUNT

	try:
		fp = open(inputFilename, 'r')
		lines = fp.readlines()
		fp.close()
	except:
		bailout ('Error: cannot read from %s' % inputFilename)

	# possible warnings

	badFesting = 'Warning: line %d, cannot parse Festing: "%s"'
	badMPD = 'Warning: line %d, cannot parse MPD: "%s"'

	strains = []

	i = 1
	for line in lines[1:]:
		i = i + 1
		valid = True

		if line[-1] == '\n':
			line = line[:-1]
		columns = line.split('\t')
		if len(columns) < 3:
			report ('Warning: Too few columns, line %d, "%s"' % \
				(i, line))
			continue

		# fix strain names that are enclosed in double quotes

		name = columns[1]
		if name:
			if (name[0] == '"') and (name[-1] == '"'):
				name = name[1:-1]

		row = {
			'line' : i,
			'mgiid' : columns[0],
			'name' : name,
			'type' : columns[2],
			'festing' : None,	# assume no Festing URL
			'mpd' : None,		# assume no MPD URL
			}

		if len(columns) >= 4:
			match = re.search ('docs/(.*)\.shtml?$', columns[3])
			if match:
				row['festing'] = match.group(1)
			elif len(columns[3]) > 0:
				report (badFesting % (i, columns[3]))
				valid = False

		if len(columns) >= 5:
			match = re.search ('strainid=([0-9]+)', columns[4])
			if match:
				row['mpd'] = match.group(1)
			elif len(columns[4]) > 0:
				report (badMPD % (i, columns[4])) 
				valid = False

		if valid:
			strains.append (row)
		else:
			INVALID_COUNT = INVALID_COUNT + 1
	return strains

def getVocab ():
	terms = {}
	results = db.sql ('select * from VOC_Term_StrainType_View', 'auto')
	for row in results:
		terms[row['term'].lower()] = row['_Term_key']
	return terms

def getStrainInfo ():
	global ID_MAP

	names = {}
	ids = {}
	strainKeys = {}

	try:
		results1 = db.sql ('''select v.accID, s.strain, s._Strain_key
			from PRB_Strain s, PRB_Strain_Acc_View v
			where s._Strain_key = v._Object_key
				and v._LogicalDB_key = 1
				and v.preferred = 1''', 'auto')

		results2 = db.sql ('''select vp.accID AS primaryID,
				vs.accID AS secondaryID
			from PRB_Strain_Acc_View vp, PRB_Strain_Acc_View vs
			where vp._Object_key = vs._Object_key
				and vp.preferred = 1
				and vs.preferred = 0
				and vp._LogicalDB_key = 1
				and vs._LogicalDB_key = 1''', 'auto')
	except:
		bailout ('Error: cannot get strain info from database')

	for row in results1:
		names[row['strain']] = row['accID']
		ids[row['accID']] = row['strain']
		strainKeys[row['accID']] = row['_Strain_key']

	for row in results2:
		primary = row['primaryID']
		secondary = row['secondaryID']

		if ID_MAP.has_key (secondary):
			ID_MAP[secondary].append (primary)
		else:
			ID_MAP[secondary] = [ primary ]

	return names, ids, strainKeys

def translateIDs (strains):
	manyIDs = 'Warning: line %d, ID %s maps to multiple primary IDs: %s'
	converted = 'Converted: secondary ID %s to primary ID %s'

	for strain in strains:
		id = strain['mgiid']
		if ID_MAP.has_key (id):
			if len(ID_MAP[id]) == 1:
				report (converted % (id, ID_MAP[id][0]))
				strain['mgiid'] = ID_MAP[id][0]
			else:
				report (manyIDs % (strain['line'], id,
					','.join (ID_MAP[id])))
	return strains

def validate (strains, names, ids, vocab):
	global INVALID_COUNT

	# possible warnings to report

	unknownID = 'Warning: line %d, ID %s does not exist in db'
	unknownType = 'Warning: line %d, unknown strain type %s'

	validStrains = []

	for strain in strains:
		id = strain['mgiid']
		line = strain['line']
		strainType = strain['type']
		valid = True

		if not ids.has_key (id):
			report (unknownID % (line, id))
			valid = False

		if not vocab.has_key(strainType.lower()):
			report (unknownType % (line, strainType))
			valid = False

		if valid:
			validStrains.append (strain)
		else:
			INVALID_COUNT = INVALID_COUNT + 1

	return validStrains

def getStandardStrains ():
	# returns dictionary of strain keys, including all those which were
	# currently flagged as "standard" in the database

	strainKeys = {}

	results = db.sql ('''select _Strain_key
		from PRB_Strain
		where standard = 1''', 'auto')

	for row in results:
		strainKeys[row['_Strain_key']] = 1

	return strainKeys

def process (validStrains, strainKeys, vocab):
	oldStandard = getStandardStrains()
	festing = [ 'MGI\tFesting\n' ]	# lines for Festing output file
	mpd = [ 'MGI\tMPD\n' ]		# lines for MPD output file
	cmds = []			# SQL statements to update strain type

	update = '''UPDATE PRB_Strain SET _StrainType_key = %d 
		WHERE _Strain_key = %d'''

	for strain in validStrains:
		id = strain['mgiid']
		strainTypeKey = vocab[strain['type'].lower()]
		festingID = strain['festing']
		mpdID = strain['mpd']
		strainKey = strainKeys[id]

		# remove this strain (which was in Janan's file) from the
		# old set of standard strains
		if oldStandard.has_key(strainKey):
			del oldStandard[strainKey]

		if festingID:
			festing.append ('%s\t%s\n' % (id, festingID))
		if mpdID:
			mpd.append ('%s\t%s\n' % (id, mpdID))

		cmds.append (update % (strainTypeKey, strainKey))

	# any strains still in 'oldStandard' were not in Janan's file, so we
	# must remove their "standard" status and must flag them as needing
	# review because of the load

	results1 = db.sql ('select max(_Annot_key) from VOC_Annot', 'auto')
	results2 = db.sql ('''select vt._Term_key
		from VOC_Term vt, VOC_Vocab vv
		where vv.name = "Generic Annotation Qualifier"
			and vv._Vocab_key = vt._Vocab_key
			and vt.term = null''', 'auto')
	results3 = db.sql ('''select vt._Term_key
		from VOC_Term vt, VOC_Vocab vv
		where vv.name = "Needs Review"
			and vv._Vocab_key = vt._Vocab_key
			and vt.term = "Needs Review - load"''', 'auto')
	results4 = db.sql ('''select _AnnotType_key
		from VOC_AnnotType
		where name = "Strain/Needs Review"''', 'auto')

	maxAnnotKey = results1[0]['']
	qualifierKey = results2[0]['_Term_key']
	needsReviewKey = results3[0]['_Term_key']
	annotTypeKey = results4[0]['_AnnotType_key']

	notStandard = '''update PRB_Strain set standard = 0 
		where _Strain_key = %d'''
	i = 0
	insert = '''insert VOC_Annot (_Annot_key, _AnnotType_key, _Object_key,
			_Term_key, _Qualifier_key)
		values (%d + %d, %d, %d, %d, %d)'''

	for strainKey in oldStandard.keys():
		i = i + 1
		cmds.append (notStandard % strainKey)
		cmds.append (insert % (maxAnnotKey, i, annotTypeKey,
			strainKey, needsReviewKey, qualifierKey) )

	return cmds, festing, mpd

def writeFiles (festing, mpd):
	files = [ (festing, './festing.txt'), (mpd, './mpd.txt') ]

	for (rows, filename) in files:
		try:
			fp = open(filename, 'w')
			fp.write (''.join (rows))
			fp.close()
		except:
			bailout ('Failed to write: %s' % filename)

	report ('wrote files for association loader: festing.txt, mpd.txt')
	return

def updateDatabase (cmds):
	# process in batches of 100

	total = len(cmds)

	try:
		while cmds:
			db.sql (cmds[:100], 'auto')
			cmds = cmds[100:]
	except:
		bailout ('Failed during database updates')

	report ('processed %d updates to PRB_Strain._StrainType_key' % total)
	return

def main():
	inputFilename = processCommandLine()
	strains = readFile (inputFilename)
	names, ids, strainKeys = getStrainInfo()
	vocab = getVocab()
	strains = translateIDs (strains)
	validStrains = validate (strains, names, ids, vocab)
	cmds, festing, mpd = process (validStrains, strainKeys, vocab)
	writeFiles (festing, mpd)
	updateDatabase (cmds)

	if INVALID_COUNT > 0:
		report ('skipped updates for %d strains which had warnings' \
			% INVALID_COUNT)
	report ('remember to save mpd.txt and festing.txt for assoc loader')
	report ('Finished successfully')
	return

if __name__ == '__main__':
	main()
