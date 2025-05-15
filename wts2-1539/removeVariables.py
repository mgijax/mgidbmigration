#
#
 
import sys 
import os
import db

db.setTrace()

results = db.sql('''
select a1.accid, e._experiment_key
from ACC_Accession a1, gxd_htexperiment e
where e._Experiment_key = a1._Object_key
and a1._MGIType_key = 42
and a1._LogicalDB_key in (189, 190)
and a1.preferred = 1
and not exists (select 1 from gxd_htexperimentvariable v where e._experiment_key = v._experiment_key)
''', 'auto')

for r in results:
    print(r['accid'])
    key = r['_experiment_key']
    runsql = '''insert into gxd_htexperimentvariable values (nextval('gxd_htexperimentvariable_seq'),%s,20475449);''' % (key)
    print(runsql)
    db.sql(runsql, None)
    db.commit()

