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

CURL1 = '''/usr/bin/curl "https://www.ncbi.nlm.nih.gov/pmc/utils/oa/oa.fcgi?id=%s" > %s '''
CURL2 = '''/usr/bin/curl "%s" > %s '''

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
--and p.value in ('21306619')
order by p.value
''', 'auto')

for p in results:

    pid = p['value']
    pubMedRef = pma.getReferenceInfo(pid)
    print()
    print(pubMedRef.getPubMedID(), pubMedRef.getPmcID())
    if pubMedRef.getPmcID() == None:
        continue
    id =  pid + '_' + pubMedRef.getPmcID()
    filename = 'littriage_gxdht/' + id + '.fcgi'
    os.system('rm -rf %s' % (filename))
    cmd = CURL1 % (pubMedRef.getPmcID(), filename)
    print(cmd)
    os.system(cmd)

    # extract ftp file from curl1
    # call curl2 command
    try:
        inFile = open(filename, 'r')
        for line in inFile.readlines():
            tokens1 = line.split("href=")
            tokens2 = tokens1[1].split('"')
            tokens3 = tokens2[1].split('/')
            print(tokens2[1])
            print(tokens3[8])
            cmd = CURL2 % (tokens2[1], 'littriage_gxdht/' + id + '.tar.gz')
            print(cmd)
            os.system(cmd)
        inFile.close()
    except:
        print(id, ": not in PMC OA")
        pass

