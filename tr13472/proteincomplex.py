import sys 
import os
import db

db.setTrace()

db.sql('delete from voc_term where _vocab_key = 171', None)

inFile = open('GO_complexes.tsv', 'r')
seq = 1
for line in inFile.readlines():
    tokens = line[:-1].split('\t')
    term = tokens[0]
    definition = tokens[1].replace("'", "''")
    sql = '''
        insert into voc_term values((select nextval('voc_term_seq')), 171, '%s', null, '%s', %s, 0, 1001, 1001, now(), now())
        ''' % (term, definition, str(seq))
    db.sql(sql, None)
    seq += 1

db.commit()
db.sql('select count(*) from voc_term where _vocab_key = 171', None)

inFile.close()

