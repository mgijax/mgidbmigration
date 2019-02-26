#!/usr/local/bin/python

'''
#
'''
 
import sys 
import os
import db
import re
import reportlib
import refSectionLib

db.setTrace()

CRT = reportlib.CRT

#
# Main
#

bibFileName = os.getenv('DBUTILS') + '/mgidbmigration/tr12963/bibworkflow/BIB_Workflow_Data.bcp'
bibFile = open(bibFileName, 'w')

rm = refSectionLib.RefSectionRemover()

# peer reveiwed articles
# have extracted text
# include
# 
# 31576675 | Db found supplement
# 31576676 | Db supplement not found
# 34026998 | No supplemental data
# 34027000 | Curator found supplement
# 37334479 | Supplement at publisher 
#

keys = db.sql('''
select r._refs_key
from BIB_Refs r
where r._referencetype_key = 31576687
and exists (select 1 from BIB_Workflow_Data d 
	where r._refs_key = d._refs_key
	and d.extractedText is not null
	and d.referenceSection is null
	and d._supplemental_key in (31576675, 31576676, 34026998, 34027000, 37334479)
	)
''', 'auto')

deleteSQL = ''
updateSQL = ''

for k in keys:
    key = k['_refs_key']

    r = db.sql('select * from BIB_Workflow_Data where _refs_key = %s' % (key), 'auto')[0]

    extractedText = r['extractedText']
    bodySection = rm.getBody(extractedText)
    referenceSection = rm.getRefSection(extractedText)
    print extractedText
    print "XXXXXXXXXXXXX"
    print bodySection
    print "XXXXXXXXXXXXX"
    print referenceSection
    print "XXXXXXXXXXXXX"

    if len(referenceSection) > 0:

	bodySection = re.sub(r'[^\x00-\x7F]','', bodySection)
        bodySection = bodySection.replace('\\', '\\\\')
        bodySection = bodySection.replace('\n', '\\n')
        bodySection = bodySection.replace('\r', '\\r')
        bodySection = bodySection.replace('|', '\\n')
        bodySection = bodySection.replace("'", "''")

	referenceSection = re.sub(r'[^\x00-\x7F]','', referenceSection)
        referenceSection = referenceSection.replace('\\', '\\\\')
        referenceSection = referenceSection.replace('\n', '\\n')
        referenceSection = referenceSection.replace('\r', '\\r')
        referenceSection = referenceSection.replace('|', '\\n')
        referenceSection = referenceSection.replace("'", "''")

    	#updateSQL += '''
	#update BIB_Workflow_Data set referenceSection = E'%s' where _refs_key = %s
	#''' % (referenceSection, key)
	#updateSQL += CRT

	deleteSQL += 'delete from BIB_Workflow_Data where _Refs_key = %s;' % (key)
	deleteSQL += CRT
	bibFile.write('%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' \
	% (key, r['hasPDF'], r['_Supplemental_key'], r['linkSupplemental'],
		bodySection, referenceSection, 
		r['_CreatedBy_key'], r['_ModifiedBy_key'],
		r['creation_date'], r['modification_date']))

#print updateSQL
#if len(updateSQL) > 0:
#    db.sql(updateSQL, None)
#    db.commit()

bibFile.close()
db.commit()

# delete existing BIB_Workflow_Data records
print deleteSQL
if len(deleteSQL) > 0:
    db.sql(deleteSQL, None)
    db.commit()
    bcpScript = os.getenv('PG_DBUTILS') + '/bin/bcpin.csh'
    bcpI = '%s %s %s' % (bcpScript, db.get_sqlServer(), db.get_sqlDatabase())
    bcpII = '"|" "\\n" mgd'
    bcpRun = '%s %s "/" %s %s' % (bcpI, 'BIB_Workflow_Data', bibFileName, bcpII)
    print bcpRun
    os.system(bcpRun)

