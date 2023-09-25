import sys 
import os
import db

db.setTrace()

inFile = open('TopSheets_MiscDiseaseModels.tsv', 'r')
lineNum = 0
for line in inFile.readlines():
    lineNum = lineNum + 1
    tokens = line[:-1].split('\t')
    jnumid = tokens[0]
    note = tokens[1]

    results = db.sql(''' select _refs_key from bib_citation_cache where jnumid = '%s' ''' % (jnumid), 'auto')

    for r in results:
        db.sql('delete from BIB_Notes where _refs_key = %s' % (r['_refs_key']), None)
        db.commit()
        cmd = ''' insert into BIB_Notes values(%s, '%s', now(), now()); ''' % (r['_refs_key'], note)
        db.sql(cmd, None)
        db.commit()

inFile.close()
