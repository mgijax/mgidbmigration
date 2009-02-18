#!/usr/local/bin/python

# add transmission references for alleles with germline transmission

import sys
import db

USAGE = 'Usage: %s <db user> <password file> <db server> <db name>\n'

def bailout (s):
	print USAGE
	print 'Error: %s' % s
	sys.exit(1)

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

# find the transmission key for germline transmissions

results = db.sql ('''select vt._Term_key
    from VOC_Term vt, VOC_Vocab vv
    where vv.name = "Allele Transmission"
	and vv._Vocab_key = vt._Vocab_key
	and vt.abbreviation = "1stGermLine"''', 'auto')
if not results:
	bailout ('Cannot find 1stGermLine _Term_key')

germLineKey = results[0]['_Term_key']

# find the reference association type for transmission references

results = db.sql ('''select _RefAssocType_key
	from MGI_RefAssocType
	where _MGIType_key = 11		-- allele
		and assocType = "Transmission"''', 'auto')
if not results:
	bailout ('Cannot find _RefAssocType_key for transmission refs')

transRefsKey = results[0]['_RefAssocType_key']

# ensure that there are no existing transmission references (this should only
# run once -- at initial migration for GTLF)

results = db.sql ('''select count(1) from MGI_Reference_Assoc
		where _RefAssocType_key = %d''' % transRefsKey, 'auto')
if results[0][''] > 0:
	bailout ('Transmission refs already exist in MGI_Reference_Assoc')

# extract reference info from database for each germline allele's MP
# annotations

results = db.sql ('''select distinct a._Allele_key, ve._Refs_key, a.symbol,
		cc.jnumID, cc.short_citation, br.authors, br.title
	from ALL_Allele a,
	    VOC_Annot va,
	    VOC_Evidence ve,
	    BIB_Refs br,
	    BIB_Citation_Cache cc,
	    ACC_Accession aa
	where a._Transmission_key = %d
	    and a._Allele_key = va._Object_key
	    and va._AnnotType_key = 1002	-- Genotype/MP
	    and va._Annot_key = ve._Annot_key
	    and ve._Refs_key = br._Refs_key
	    and br._Refs_key = cc._Refs_key
	    and cc.jnumID = aa.accID
	order by a._Allele_key,
	    br.year, 
	    aa.numericPart''' % germLineKey, 'auto')

# we want to only keep the first reference for each allele

alleleRef = {}
multiRefs = {}
refs = {}

for row in results:
	alleleKey = row['_Allele_key']
	refsKey = row['_Refs_key']

	if not alleleRef.has_key(alleleKey):
		alleleRef[alleleKey] = refsKey
	else:
		multiRefs[alleleKey] = 1

	if not refs.has_key(refsKey):
		refs[refsKey] = row

# now add the new references to the database (assume single-user mode)

results = db.sql ('select max(_Assoc_key) from MGI_Reference_Assoc', 'auto')
if not results:
	assocKey = 0
else:
	assocKey = results[0]['']

cmd = '''insert MGI_Reference_Assoc (_Assoc_key, _Refs_key, _Object_key,
		_MGIType_key, _RefAssocType_key)
	values (%d, %d, %d, 11, %d)'''

for (alleleKey, refsKey) in alleleRef.items():
	assocKey = assocKey + 1
	db.sql (cmd % (assocKey, refsKey, alleleKey, transRefsKey), 'auto')

# reporting

print '=' * 60
print 'Transmission References:'
print '  - for all alleles: %d' % len(alleleRef)
print '  - for alleles which had >1 reference: %d' % len(multiRefs)
print '  - distinct references used: %d' % len(refs)
print '=' * 60
print 'Transmission Refs for alleles which had >1 reference:'
print 'Allele\tJ: Num\tShort Citation\tTitle'

for alleleKey in multiRefs.keys():
	refsKey = alleleRef[alleleKey]
	symbol = refs[refsKey]['symbol']
	jnum = refs[refsKey]['jnumID']
	citation = str(refs[refsKey]['short_citation'])
	title = str(refs[refsKey]['title'])

	print '%s\t%s\t%s\t%s' % (symbol, jnum, citation, title)
