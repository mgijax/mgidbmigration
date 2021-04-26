import sys 
import os
import db

db.setTrace()

results = db.sql('''
select m._marker_key, m.symbol, a.accID
from go_tracking gt, mrk_marker m, acc_accession a
where gt._completedby_key is not null
and gt._marker_key = m._marker_key
and gt._marker_key = a._object_key
and a._mgitype_key = 2
and a._logicaldb_key = 1
and a.prefixpart = 'MGI:'
and a.preferred = 1
and not exists (select 1 from voc_annot v
        where v._annottype_key = 1000
        and gt._marker_key = v._object_key
        )
and not exists (select 1 from BIB_GOXRef_View r where m._marker_key = r._Marker_key)
order by symbol
''', 'auto')

for r in results:
    print('GO:0005575\t' + r['accID'] + '\t' + 'J:73796\tND\t\t\tdbo\t20210426\t\t\t')
    print('GO:0003674\t' + r['accID'] + '\t' + 'J:73796\tND\t\t\tdbo\t20210426\t\t\t')
    print('GO:0008150\t' + r['accID'] + '\t' + 'J:73796\tND\t\t\tdbo\t20210426\t\t\t')


