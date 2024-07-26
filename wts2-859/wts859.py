#
# Lexicon data links to MMRRC are broken
#
 
import sys 
import os
import db

db.setTrace()

db.sql('''select a._allele_key, a.symbol, aa.accid, n._note_key, n.note
into temp mmrrcallele
from ALL_Allele a, MGI_Note n, ACC_Accession aa
where a._allele_key = n._object_key
and n._notetype_key = 1020
and n._mgitype_key = 11
and n.note like '%http://mmrrc.mousebiology.or%'
and a._allele_key = aa._object_key
and aa._mgitype_key = 11
and aa._logicaldb_key = 1
order by a.symbol
''', None)

results = db.sql('select * from mmrrcallele', 'auto')

updateSQL = ''
for r in results:
    accid = r['accid']
    nkey = r['_note_key']
    newnote = '''See also, <A HREF=\"https://www.mmrrc.org/catalog/locus_detail.php?mgi_id=''' + accid + '''\">data</A> as provided by Lexicon Genetics, Inc.'''
    updateSQL += "update MGI_Note set note = '%s' where _note_key = %s;\n" % (newnote, nkey)

print(updateSQL)
#db.sql(updateSQL, None)

#results = db.sql(''' select m.*, n.note from mmrrcallele m, mgi_note n where m._note_key = n._note_key''', 'auto')
#print(results)

