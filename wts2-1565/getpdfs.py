#
# use this to test the:
#   pubmed agent 
#   directly to the eutils/api
#
# usage:  
# edit pubmedids as needed
# $PYTHON testeutilsapi.py
#

import sys 
import os
import db
import PdfParser
import PubMedAgent
import Pdfpath
import HttpRequestGovernor
import time
gov = HttpRequestGovernor.HttpRequestGovernor(.5, 120, 7200, 172800)

db.setTrace()

pma = PubMedAgent.PubMedAgentMedline()

CURL_IT = '''/usr/bin/curl "https://www.ncbi.nlm.nih.gov/pmc/utils/oa/oa.fcgi?id=%s" > %s '''

results = db.sql('''
select distinct p.value
from GXD_HTExperiment e, ACC_Accession a, MGI_Property p
where e._curationstate_key = 20475421 /* Done */
and e._experiment_key = a._object_key
and a._mgitype_key = 42 /* ht experiment type */
and a.preferred = 1
and e._experiment_key = p._object_key
and p._mgitype_key = 42
and p._propertyterm_key = 20475430
and not exists (select 1 from BIB_Citation_Cache c where p.value = c.pubmedid)
order by p.value
''', 'auto')

for p in results:
    pid = p['value']
    filename = 'littriage_gxdhtml/PMID_' + pid + '.pdf'
    os.system('rm -rf %s' % (filename))
    pubMedRef = pma.getReferenceInfo(pid)
    print(pubMedRef.getPubMedID(), pubMedRef.getPmcID())
    cmd = CURL_IT % (pubMedRef.getPmcID(), filename)
    print(cmd)
    print()
    os.system(cmd)
