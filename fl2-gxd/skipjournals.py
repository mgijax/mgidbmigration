import sys 
import os
import db
import reportlib

db.setTrace()

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

#
# Main
#

db.useOneConnection(1)

db.sql('delete from VOC_Term where _vocab_key = 134',None)

# select all jouranls that have been Indexed/Full-coded at least once
db.sql('''
select distinct r.journal
into temp table journalsUsed
from bib_refs r
where r.journal is not null
and exists (select 1 from bib_workflow_status s
        where r._refs_key = s._refs_key
        and s._group_key = 31576665
        and s.isCurrent = 1
        and s._status_key in (31576673,31576674)
        )
''', None)

# select journals that have not been Indexed/Full-coded
# and do not exist in journalsUsed set

results = db.sql('''
select distinct journal
from bib_refs r
where r.journal is not null
and not exists (select 1 from bib_workflow_status s
        where r._refs_key = s._refs_key
        and s._group_key = 31576665
        and s.isCurrent = 1
        and s._status_key in (31576673,31576674)
        )
and not exists (select 1 from journalsUsed j
        where r.journal = j.journal)
order by journal
''', 'auto')

seqNum = 1
for r in results:
	term = r['journal'].replace("'","''")
	addSQL = '''
	insert into VOC_Term values(
	(select max(_Term_key) + 1 from VOC_Term),134,'%s',null,null,%d,0,1001,1001,now(),now());
	''' % (term, seqNum)
	seqNum += 1
	print(addSQL)
	db.sql(addSQL, None)
	db.commit()

results = db.sql('select count(*) as count from voc_term where _vocab_key = 134', 'auto')
print(str(results['']))

db.useOneConnection(0)

