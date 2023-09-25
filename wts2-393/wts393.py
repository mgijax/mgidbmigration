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

    results = db.sql(''' 
        select r._refs_key from bib_citation_cache r, bib_workflow_tag bt, voc_term t
        where r.jnumid = '%s' 
        and r._refs_key = bt._refs_key
        and bt._tag_key = t._term_key
        and t.term = 'AP:MiscellaneousDisease'
        ''' % (jnumid), 'auto')

    for r in results:
        db.sql('delete from BIB_Notes where _refs_key = %s' % (r['_refs_key']), None)
        db.commit()
        cmd = ''' insert into BIB_Notes values(%s, '%s', now(), now()); ''' % (r['_refs_key'], note)
        db.sql(cmd, None)
        db.commit()

inFile.close()
