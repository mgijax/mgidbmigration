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
(
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
union
select distinct p.value, array_to_string(array_agg(distinct a.accid),'|') as exptId
from GXD_HTExperiment e, ACC_Accession a, MGI_Property p
where e._curationstate_key = 20475421 /* Done */
and e._experiment_key = a._object_key
and a._mgitype_key = 42 /* ht experiment type */
and a.preferred = 1
and e._experiment_key = p._object_key
and p._mgitype_key = 42
and p._propertyterm_key = 20475430
and exists (select 1 from BIB_Citation_Cache c where p.value = c.pubmedid and c.jnumid is null)
group by p.value
)
order by value
''', 'auto')

#results = db.sql('''
#select pubmedid as value
#from bib_citation_cache 
#where mgiid in (
#'MGI:7736783',
#'MGI:7736784',
#'MGI:7736671',
#'MGI:7736677',
#'MGI:7736691',
#'MGI:7736679',
#'MGI:7736682',
##'MGI:7736694',
#'MGI:7736698',
#'MGI:7736707',
#'MGI:7736719',
#'MGI:7736747',
#'MGI:7736766',
#'MGI:7736767',
#'MGI:7736768',
#'MGI:7736775',
#'MGI:7736781',
#'MGI:7736788',
#'MGI:7736803',
#'MGI:7736814',
#'MGI:7736821',
#'MGI:7736822',
#'MGI:7736830',
#'MGI:7736836',
#'MGI:7736875',
#'MGI:7736894',
#'MGI:7736895',
#'MGI:7736902',
#'MGI:7736905',
#'MGI:7736919',
#'MGI:7736923',
#'MGI:7736933',
#'MGI:7736935',
#'MGI:7736936',
#'MGI:7736937',
#'MGI:7736946',
#'MGI:7736965',
#'MGI:7736971',
#'MGI:7736972',
#'MGI:7736994',
#'MGI:7737003',
#'MGI:7737037',
#'MGI:7737046',
#'MGI:7737052',
#'MGI:7737061',
#'MGI:7737064',
#'MGI:7737071',
#'MGI:7737072',
#'MGI:7737076',
#'MGI:7737078',
##'MGI:7737080',
#'MGI:7737088',
#'MGI:7737116',
#'MGI:7737119',
#'MGI:7737140',
#'MGI:7737124',
#'MGI:7737129',
#'MGI:7737146',
#'MGI:7737153',
#'MGI:7737154',
#'MGI:7737158'
#)
#''', 'auto')
#MGI:7737167
#MGI:7737182
#MGI:7737197
#MGI:7737203
#MGI:7737205
#MGI:7737207
#MGI:7737183
#MGI:7737346

for p in results:

    pid = p['value']
    pubMedRef = pma.getReferenceInfo(pid)
    print()
    print(pubMedRef.getPubMedID(), pubMedRef.getPmcID())
    if pubMedRef.getPmcID() == None:
        print(pid, ": pmc is not in pubmed")
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

