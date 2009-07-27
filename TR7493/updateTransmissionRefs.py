#!/usr/local/bin/python

# add transmission references for alleles with germline transmission

import sys
import db
import time

USAGE = 'Usage: %s <db user> <password file> <db server> <db name>\n'

STARTTIME = time.time()

def bailout (s):
	print USAGE
	print 'Error: %s' % s
	sys.exit(1)

def debug (s):
	sys.stderr.write ('%8.3f : %s\n' % (time.time() - STARTTIME, s))
	return

# extract command-line arguments

if len(sys.argv) != 5:
	bailout ('Invalid command-line')

[ user, pwdFile, server, dbname ] = sys.argv[1:]

# read password from file

try:
	fp = open (pwdFile, 'r')
	password = fp.readline().strip()
	fp.close()
except:
	bailout ('Cannot read: %s' % pwdFile)

# set up database connection and try a sample query

db.set_sqlLogin (user, password, server, dbname)

try:
	db.useOneConnection(1)
	db.sql ('select count(1) from MGI_dbInfo', 'auto')
except:
	bailout ('Cannot read from database')

debug ('finished initialization')

# find the transmission key for germline transmissions

results = db.sql ('''select vt._Term_key
    from VOC_Term vt, VOC_Vocab vv
    where vv.name = "Allele Transmission"
	and vv._Vocab_key = vt._Vocab_key
	and vt.term = "Germline"''', 'auto')
if not results:
	bailout ('Cannot find Germline _Term_key')

germLineKey = results[0]['_Term_key']
debug ('got germline transmission key')

# find the reference association type for transmission references

results = db.sql ('''select _RefAssocType_key
	from MGI_RefAssocType
	where _MGIType_key = 11		-- allele
		and assocType = "Transmission"''', 'auto')
if not results:
	bailout ('Cannot find _RefAssocType_key for transmission refs')

transRefsKey = results[0]['_RefAssocType_key']
debug ('got transmission ref assoc type key')

# find the reference association type for original references

results = db.sql ('''select _RefAssocType_key
	from MGI_RefAssocType
	where _MGIType_key = 11		-- allele
		and assocType = "Original"''', 'auto')
if not results:
	bailout ('Cannot find _RefAssocType_key for original refs')

originalRefsKey = results[0]['_RefAssocType_key']
debug ('got original ref assoc type key')

# ensure that there are no existing transmission references (this should only
# run once -- at initial migration for GTLF)

results = db.sql ('''select count(1) from MGI_Reference_Assoc
		where _RefAssocType_key = %d''' % transRefsKey, 'auto')
if results[0][''] > 0:
	bailout ('Transmission refs already exist in MGI_Reference_Assoc')
debug ('verified no existing transmission refs exist')

# get the set of all germline allele keys

results = db.sql ('''select _Allele_key
	from ALL_Allele
	where _Transmission_key = %d''' % germLineKey, 'auto')
germlineAlleles = []
for row in results:
	germlineAlleles.append (row['_Allele_key'])
debug ('got %d germline allele keys' % len(germlineAlleles))

# extract original references for germline alleles (this is the fallback
# reference for any that don't have MP annotations)

refs = {}

results = db.sql ('''select distinct a._Allele_key, ra._Refs_key, a.symbol,
		cc.jnumID, cc.short_citation, br.authors, br.title
	from ALL_Allele a,
		MGI_Reference_Assoc ra,
		BIB_Refs br,
		BIB_Citation_Cache cc
	where a._Transmission_key = %d
		and a._Allele_key = ra._Object_key
		and ra._RefAssocType_key = %d
		and ra._Refs_key = br._Refs_key
		and br._Refs_key = cc._Refs_key''' % (germLineKey,
			originalRefsKey), 'auto')
originalRefs = {}
for row in results:
	refsKey = row['_Refs_key']
	originalRefs[row['_Allele_key']] = refsKey

	if not refs.has_key(refsKey):
		refs[refsKey] = row
debug ('got %d original references' % len(originalRefs))

# extract reference info from database for each germline allele's MP
# annotations.  (Do not gather MP references for targeted alleles, though,
# as we do not want them for Transmission references in that case.)

results = db.sql ('''select distinct a._Allele_key, ve._Refs_key, a.symbol,
		cc.jnumID, cc.short_citation, br.authors, br.title
	from ALL_Allele a,
	    VOC_Annot va,
	    VOC_Evidence ve,
	    BIB_Refs br,
	    BIB_Citation_Cache cc,
	    GXD_AlleleGenotype gg,
	    ACC_Accession aa
	where a._Transmission_key = %d
	    and a._Allele_key = gg._Allele_key
	    and gg._Genotype_key = va._Object_key
	    and va._AnnotType_key = 1002	-- Genotype/MP
	    and va._Annot_key = ve._Annot_key
	    and ve._Refs_key = br._Refs_key
	    and br._Refs_key = cc._Refs_key
	    and cc.jnumID = aa.accID
	    and a._Allele_Type_key not in (847116, 847117, 847118, 847119,
	    	847120)
	order by a._Allele_key,
	    br.year, 
	    aa.numericPart''' % germLineKey, 'auto')

# we want to only keep the first MP reference for each allele

alleleRef = {}
multiRefs = {}

for row in results:
	alleleKey = row['_Allele_key']
	refsKey = row['_Refs_key']

	if not alleleRef.has_key(alleleKey):
		alleleRef[alleleKey] = refsKey
	else:
		multiRefs[alleleKey] = 1

	if not refs.has_key(refsKey):
		refs[refsKey] = row
debug ('got %d MP refs' % len(alleleRef))

# now add the new references to the database (assume single-user mode)

results = db.sql ('select max(_Assoc_key) from MGI_Reference_Assoc', 'auto')
if not results:
	assocKey = 0
else:
	assocKey = results[0]['']
debug ('got max assoc key')

cmd = '''insert MGI_Reference_Assoc (_Assoc_key, _Refs_key, _Object_key,
		_MGIType_key, _RefAssocType_key)
	values (%d, %d, %d, 11, %d)'''

mpCount = 0
originalCount = 0
missingCount = 0

for alleleKey in germlineAlleles:
	# for each allele, prefer an MP ref over an original ref

	if alleleRef.has_key(alleleKey):
		refsKey = alleleRef[alleleKey]
		mpCount = mpCount + 1
	elif originalRefs.has_key(alleleKey):
		refsKey = originalRefs[alleleKey]
		originalCount = originalCount + 1
	else:
		print 'germline allele (%d) has no reference' % alleleKey
		missingCount = missingCount + 1
		continue

	assocKey = assocKey + 1
	db.sql (cmd % (assocKey, refsKey, alleleKey, transRefsKey), 'auto')
debug ('finished inserts')

# reporting

print '=' * 60
print 'Transmission Reference Stats:'
print '  - germline alleles: %d' % len(germlineAlleles)
print '  - germline alleles using MP reference: %d' % mpCount
print '  - germline alleles using original reference: %d' % originalCount
print '  - germline alleles which had >1 MP reference: %d' % len(multiRefs)
print '  - germline alleles with no references: %d' % missingCount
print '  - distinct references used: %d' % len(refs)
print '=' * 60
print 'Transmission Refs for alleles which had >1 MP reference:'
print 'Allele\tJ: Num\tShort Citation\tTitle'

for alleleKey in multiRefs.keys():
	refsKey = alleleRef[alleleKey]
	symbol = refs[refsKey]['symbol']
	jnum = refs[refsKey]['jnumID']
	citation = str(refs[refsKey]['short_citation'])
	title = str(refs[refsKey]['title'])

	print '%s\t%s\t%s\t%s' % (symbol, jnum, citation, title)
