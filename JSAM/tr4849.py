#!/usr/local/bin/python
import sys
import os
import db
import mgi_utils
import reportlib
import string
import regex
import getopt

# Generate all BCP files for loading group of select sequence records
# and associated data for testing the JSAM WI.
#
# Steps:
#   1. Read in seq_input to create SEQ_Sequence BCP file
#   2. Read in source_input to create PRB_Source BCP file
#   3. Create SEQ_Source_Assoc BCP file
#   4. Read in provider_input to create ACC_Accession BCP file
#      and ACC_AccessionReference BCP file
#   5. Read in ref_input to create MGI_Reference_Assoc BCP file

def showUsage():
        '''
        # requires:
        #
        # effects:
        # Displays the correct usage of this program and exits
        # with status of 1.
        #
        # returns:
        '''

        usage = 'usage: %s -S server\n' % sys.argv[0] + \
                '-D database\n' + \
                '-U user\n' + \
                '-P password file\n'
        exit(1, usage)

def exit(status, message = None):
        '''
        # requires: status, the numeric exit status (integer)
        #           message (string)
        #
        # effects:
        # Print message to stderr and exits
        #
        # returns:
        #
        '''

        if message is not None:
                sys.stderr.write('\n' + str(message) + '\n')

        sys.exit(status)


##################################################################
# FUNCTION: checkNotNone
# INPUTS: 
# RETURNS: none
# SIDE EFFECTS: none
# ASSUMES: nothing
# COMMENTS: 
##################################################################
def checkNotNone(value,label):
        if value == None:
                die("Got value None for %s!!" % label)
        debug("%s = %s" % (label, str(value)))


def getSeqTypeKey(values):
	
	seqTypeKeys = {}

	results = db.sql('select abbreviation,_Term_key from VOC_Term where _Vocab_key = 22','auto')
	for result in results:
		seqTypeKeys[result['abbreviation']] = result['_Term_key']

	#print seqTypeKeys

	return seqTypeKeys

def getSeqProviderKey(values):

	seqProvKeys = {}

	results = db.sql('select term,_Term_key from VOC_Term where _Vocab_key = 26','auto')
	for result in results:
		seqProvKeys[result['term']] = result['_Term_key']

	#print seqProvKeys

	return seqProvKeys

def getSeqQualityKey(values):

	seqQualityKeys = {}

	results = db.sql('select abbreviation,_Term_key from VOC_Term where _Vocab_key = 20','auto')
	for result in results:
		seqQualityKeys[result['abbreviation']] = result['_Term_key']

#	print seqQualityKeys

	return seqQualityKeys

def getSeqStatusKey(values):

	seqStatusKeys = {}

	results = db.sql('select abbreviation,_Term_key from VOC_Term where _Vocab_key = 21','auto')
	for result in results:
		seqStatusKeys[result['abbreviation']] = result['_Term_key']

#	print seqStatusKeys

	return seqStatusKeys

def getUserKey(value):

	userKey = 999
	
	results = db.sql('select _User_key from MGI_User where login = "blk"','auto')
#	print results
	userKey = results[0]['_User_key']

	return userKey

def getStrainKey(value):

	stainKey = 999

	cmd = 'select _strain_key from PRB_Strain where strain = "%s"' % (value)
#	print cmd

	results = db.sql(cmd,'auto')
	strainKey = results[0]['_strain_key']
	#print "strainkey=",strainKey

	return strainKey

def getTissueKey(value):

	tissKey = 999

	cmd = 'select _tissue_key from PRB_Tissue where tissue = "%s"' % (value)
#	print cmd

	results = db.sql(cmd,'auto')
	tissKey = results[0]['_tissue_key']
	#print "tisskey=",tissKey

	return tissKey

def getGenderKey(value):

	genderKey = 999

	cmd = 'select _term_key from VOC_Term_Gender_View where term = "%s"' % (value)
#	print cmd

	results = db.sql(cmd,'auto')
	genderKey = results[0]['_term_key']
	#print "genderkey=",genderKey

	return genderKey

def getCelllineKey(value):

	celllineKey = 999

	cmd = 'select _term_key from VOC_Term_Cellline_View where term = "%s"' % (value)
#	print cmd

	results = db.sql(cmd,'auto')
	celllineKey = results[0]['_term_key']
	#print "celllinekey=",celllineKey

	return celllineKey

def getSegmentKey(value):

	segKey = 999

	cmd = 'select _term_key from VOC_Term_SegmentType_View where term = "%s"' % (value)
#	print cmd

	results = db.sql(cmd,'auto')
	segKey = results[0]['_term_key']
	#print "segKey=",segKey

	return segKey

def getVectorKey(value):

	vecKey = 999

	cmd = 'select _term_key from VOC_Term_SegVectorType_View where term = "%s"' % (value)
#	print cmd

	results = db.sql(cmd,'auto')
	vecKey = results[0]['_term_key']
	#print "vecKey=",vecKey

	return vecKey

def testNewAccessionIDs(ids):

	foundids = {}
	newids = []

	cmd = 'select accID from ACC_Accession where accID in ("' + string.joinfields(ids,'","') + '")'

#	print cmd
	results = db.sql(cmd,'auto')
#	print results

	# Make dictionary of ids found in MGD
	for result in results:
		seqID = result['accID']
		if not foundids.has_key(seqID):
			foundids[seqID] = seqID

	# Make list of ids not in foundids
	for id in ids:
		if not foundids.has_key(id):
			newids = newids + [id]

	return newids,foundids

def init():

        global seqFile,sourceFile,seqChunkFile,accFile,passwordFileName
        global seqFileName,sourceFileName,seqChunkFileName,accFileName 
	global seqsourceFileName,seqsourceFile 
	global accrefFile,accrefFileName
	global refFile,refFileName

        try:
                 optlist, args = getopt.getopt(sys.argv[1:], 'S:D:U:P:')
        except:
                 showUsage()

        #
        # Set server, database, user, passwords depending on options
        # specified by user.
        #
        server = None
        database = None
        user = None
        password = None

        for opt in optlist:
                if opt[0] == '-S':
                        server = opt[1]
                elif opt[0] == '-D':
                        database = opt[1]
                elif opt[0] == '-U':
                        user = opt[1]
                elif opt[0] == '-P':
                        passwordFileName = opt[1]
                else:
                        showUsage()

     # Initialize db.py DBMS parameters
        password = string.strip(open(passwordFileName, 'r').readline())
        db.set_sqlLogin(user, password, server, database)
  
        head1,tail1 = os.path.split('seqFile')
        seqFileName = tail1 + '.SEQ_Sequence.bcp'
        sourceFileName = tail1 + '.PRB_Source.bcp'
	seqsourceFileName = tail1 + '.SEQ_Source_Assoc.bcp'
	accFileName = tail1 + '.ACC_Accession.bcp'
	accrefFileName = tail1 + '.ACC_AccessionReference.bcp'
	refFileName = tail1 + '.MGI_Reference_Assoc.bcp'

        try:
                seqFile = open(seqFileName, 'w')
        except:
                exit(1, 'Could not open file %s\n' % seqFileName)


        try:
                sourceFile = open(sourceFileName, 'w')
        except:
                exit(1, 'Could not open file %s\n' % sourceFileName)


        try:
                seqsourceFile = open(seqsourceFileName, 'w')
        except:
                exit(1, 'Could not open file %s\n' % seqsourceFileName)


        try:
                accFile = open(accFileName, 'w')
        except:
                exit(1, 'Could not open file %s\n' % accFileName)


        try:
                accrefFile = open(accrefFileName, 'w')
        except:
                exit(1, 'Could not open file %s\n' % accrefFileName)


        try:
                refFile = open(refFileName, 'w')
        except:
                exit(1, 'Could not open file %s\n' % refFileName)



#        print seqFileName,sourceFileName,seqsourceFileName,accFileName,accrefFileName,refFileName


# Main

init()

#set default keyvalue and acckey
seqkey = 0
acckey = 0
sourcekey = 0
seqassockey = 0
assockey = 0

TAB = reportlib.TAB
CRT = reportlib.CRT

accID = ''

# Store sequence key for each accession ID
seqkeys = {}

# Store source key for each accession ID
sourcekeys = {}

#print "getting max source key"
results = db.sql('select max(_Source_key) as sourcekey from PRB_Source','auto')
sourcekey = results[0]['sourcekey']
#print "got max source key",sourcekey

#print "getting max accession key"
results = db.sql('select max(_accession_key) as acckey from ACC_Accession','auto')
acckey = results[0]['acckey']
#print "got max accession key",acckey

#print "getting max association key"
results = db.sql('select max(_assoc_key) as assockey from MGI_Reference_Assoc','auto')
assockey = results[0]['assockey']
#print "got max association key",assockey

#print "getting max sequence key"
results = db.sql('select max(_Sequence_key) as seqkey from SEQ_Sequence','auto')
#print "results=",results
seqkey = results[0]['seqkey']
if results[0]['seqkey'] == None:
	seqkey = 0
else:
	seqkey = results[0]['seqkey']
#print "got max sequence key",seqkey

#print "getting max sequence assoc key"
results = db.sql('select max(_Assoc_key) as seqassockey from SEQ_Source_Assoc','auto')
#print "results=",results
if results[0]['seqassockey'] == None:
	seqassockey = 0
else:
	seqassockey = results[0]['seqassockey']

seqre = regex.compile("\([A-Z0-9,]+\)\t\([D,R,P]\)\t\([H,M,L]\)\t\(A\)\t\([A-Za-z\:\-]+\)\t\([0-9]+.+\)")

# old regex when keys hard-coded in source_input file
#sourcere = regex.compile("\([A-Z0-9,]+\)\t\(.+\)")
sourcere = regex.compile("\([A-Z0-9,]+\)\t\([0-9A-Za-z ]+\)\t\([0-9A-Za-z ]+\)\t\([0-9]+\)\t\([0-9A-Za-z /]+\)\t\([A-Za-z ]+\)\t\([A-Za-z ]+\)\t\([0-9A-Za-z ]+\)\t\(.*\)")

providerre = regex.compile("\([A-Z0-9]+\)\t\([0-9]+\)")

refre = regex.compile("\([A-Z0-9]+\)\t\([J\:0-9]*\)\t\([0-9]*\)")

# Get keys for values that may appear in input file
seqTypeKeys = getSeqTypeKey(['D','R','P'])
#print 'seqTypeKeys=',seqTypeKeys
seqQualityKeys = getSeqQualityKey(['H','M','L'])
seqStatusKeys = getSeqStatusKey(['F','D'])
seqProviderKeys = getSeqProviderKey(['GenBank:Rodent','SWISS-PROT','TrEMBL','GenBank:HTC','GenBank:EST'])
#print "seqProviderKeys=",seqProviderKeys
userkey = getUserKey('blk')

# Set creation date
creationdate = '10/17/2003'

# Set modification date
modificationdate = '10/17/2003'


# Read in and process seq_input,
# and write SEQ_Sequence BCP file

fd = open('seq_input','r')
line = fd.readline()
while line:
   #print line
   if seqre.match(line) != -1:

	seqkey = seqkey + 1
	
	accid = seqre.group(1)

	accids = string.split(accid,',')
#	print accids
	for id in accids:
		if seqkeys.has_key(id):
			print "############ Error ##############"
		else:
			seqkeys[id] = seqkey

	seqtypetext = seqre.group(2)
#	print 'seqtypetext=',seqtypetext
	if seqTypeKeys.has_key(seqtypetext):
		seqtype = seqTypeKeys[seqtypetext]
	else:
		seqtype = 999
	seqqualitytext = seqre.group(3)
	if seqQualityKeys.has_key(seqqualitytext):
		seqquality = seqQualityKeys[seqqualitytext]
	else:
		seqquality = 999
	seqstatustext = seqre.group(4)
	if seqstatustext != '':
		if seqStatusKeys.has_key(seqstatustext):
			seqstatus = seqStatusKeys[seqstatustext]
		else:
			seqstatus = 999
	seqprovidertext = seqre.group(5)
#	print "Seqprovidertext=",seqprovidertext
	if seqprovidertext != '':
		if seqProviderKeys.has_key(seqprovidertext):
			seqprovider = seqProviderKeys[seqprovidertext]
		else:
			seqprovider = 999
	#print accid,seqtype,seqquality,seqprovider
	rest = seqre.group(6)
	#print rest

	line = "%s\t" % seqkey + \
		      "%s\t" % seqtype + \
		      "%s\t" % seqquality + \
	              "%s\t" % seqstatus + \
	              "%s\t" % seqprovider + \
		      "%s\t" % rest + \
		      "%s\t" % userkey + \
		      "%s\t" % userkey + \
		      creationdate + "\t" + \
		      modificationdate + "\n"

	seqFile.write(line)

   line = fd.readline()

fd.close()

# Read in and process source_input,
# and write PRB_Source BCP file

fd = open('source_input','r')
line = fd.readline()
while line:
   #print line
   if sourcere.match(line) != -1:

	# Increment source record key
	sourcekey = sourcekey + 1
	
	accid = sourcere.group(1)
	#print "accid=",accid

	accids = string.split(accid,',')
	#print 'accids=',accids

	# Iterate over each accession ID for source record and store
	# the sequence record keys for each sequence record key
	for id in accids:
		if sourcekeys.has_key(id):
			sourcekeys[id] = sourcekeys[id] + [sourcekey]
		else:
			sourcekeys[id] = [sourcekey]

	# Process clone/probe (segment) type key
	segtype = sourcere.group(2)
	#print "segtype=",segtype
	type = getSegmentKey(segtype)
	#print "type=",type

	# Process clone/probe vector type key
	vectype = sourcere.group(3)
	#print "vectype=",vectype
	vtype = getVectorKey(vectype)
	#print "vtype=",vtype

	# Process organism
	org = sourcere.group(4)
	#print "org=",org

	# Process strain
	strain = sourcere.group(5)
	#print "strain=",strain
	strainkey = getStrainKey(strain)
	#print "strainkey=",strainkey

	# Process tissue
	tissue = sourcere.group(6)
	#print "tissue=",tissue
	tissuekey = getTissueKey(tissue)
	#print "tissuekey=",tissuekey

	# Process gender
	gender = sourcere.group(7)
	#print "gender=",gender
	genderkey = getGenderKey(gender)
	#print "genderkey=",genderkey

	# Process cell line
	cellline = sourcere.group(8)
	#print "cellline=",cellline
	celllinekey = getCelllineKey(cellline)
	#print "celllinekey=",celllinekey

	# Process rest

	rest = sourcere.group(9)
#	print rest

	line = "%s\t" % sourcekey + \
		      "%s\t" % type + \
		      "%s\t" % vtype + \
		      "%s\t" % org + \
		      "%s\t" % strainkey + \
		      "%s\t" % tissuekey + \
		      "%s\t" % genderkey + \
		      "%s\t" % celllinekey + \
		      "%s\t" % rest + \
		      "%s\t" % userkey + \
		      "%s\t" % userkey + \
		      creationdate + "\t" + \
		      modificationdate + "\n"

	sourceFile.write(line)

   line = fd.readline()

fd.close()

#print "sourcekeys=",sourcekeys

# Generate BCP file for SEQ_Source_Assoc BCP file
for id in seqkeys.keys():
	for sourceid in sourcekeys[id]:
		seqassockey = seqassockey + 1
		line = "%s\t" % seqassockey + \
			"%s\t" % seqkeys[id] + \
			"%s\t" % sourceid + \
			      "%s\t" % userkey + \
			      "%s\t" % userkey + \
			      creationdate + "\t" + \
			      modificationdate + "\n"

		seqsourceFile.write(line)


# Generate BCP file for ACC_Accession and ACC_AccessionReference 
# ACC_Accession BCP file will create a new accID record and 
# relate to sequence object
# ACC_AccessionReference BCP file will associate a reference to
# the accID (J:78120 is used even though it is not accurate).

# seqID regex to separate prefix from numeric part of IDs
prefixre = regex.compile("\([A-Z_\]+\)\([0-9]+\)")
# for TrEMBL seqIDs like Q8C8K9
trprefixre = regex.compile("\([A-Z0-9_\]+\)\([0-9]+\)")

# Read in file relating seqIDs to provider
fd = open('provider_input','r')
line = fd.readline()
while line:
#   print line
   if providerre.match(line) != -1:

	# Increment accID record key
	acckey = acckey + 1
	
	id = providerre.group(1)
	logicaldbkey = providerre.group(2)
#	print id,logicaldbkey

	# separate prefix from numeric part in ids
	if prefixre.match(id) > -1:
		prefix = prefixre.group(1)
		numeric = prefixre.group(2)
	elif trprefixre.match(id) > -1:
		prefix = trprefixre.group(1)
		numeric = trprefixre.group(2)
	else:
		prefix = id
		numeric = ""

	line = "%s\t" % acckey + \
		id + "\t" + \
		"%s\t" % prefix + \
		"%s\t" % numeric + \
		"%s\t" % logicaldbkey + \
		"%s\t" % seqkeys[id] + \
		"19\t" + \
		"0\t\t" + \
	      "%s\t" % userkey + \
	      "%s\t" % userkey + \
	      creationdate + "\t" + \
	      modificationdate + "\n"

	accFile.write(line)

	line = "%s\t" % acckey + \
		"79081\t" + \
	      "%s\t" % userkey + \
	      "%s\t" % userkey + \
	      creationdate + "\t" + \
	      modificationdate + "\n"

	accrefFile.write(line)

   else:
	print "ERROR reading line:",line

   line = fd.readline()

fd.close()

# Create BCP file for MGI_Reference_Assoc table

# Read in file relating seqIDs to references
fd = open('ref_input','r')
line = fd.readline()
while line:
#   print line
   if refre.match(line) != -1:

	# Increment association record key
	assockey = assockey + 1
	
	id = refre.group(1)
	refkey = refre.group(3)
#	print id,refkey

	line = "%s\t" % assockey + \
		"%s\t" % refkey + \
		"%s\t" % seqkeys[id] + \
		"19\t" + \
		"1000\t" + \
	      "%s\t" % userkey + \
	      "%s\t" % userkey + \
	      creationdate + "\t" + \
	      modificationdate + "\n"

	refFile.write(line)


   else:
	print "ERROR reading line:",line

   line = fd.readline()

fd.close()



#bcpFiles()
exit(0)

