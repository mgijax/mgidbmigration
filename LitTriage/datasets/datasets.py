#!/usr/local/bin/python

'''
#
# migration of bib_dataset/bib_dataset_assoc to bib_workflow_status, bib_workflow_tag
#
'''
 
import sys 
import os
import db
import mgi_utils

db.setTrace()

wf_status = '%s|%s|%s|%s|1|1001|1001|%s|%s\n'

wf_tag = '%s|%s|%s|1001|1001|%s|%s\n'

currentDate = mgi_utils.date('%m/%d/%Y')

#
# ap/gxd/go/qtl : indexed
#
def apgxdgoqtl_indexed():
   #
   # selected : any
   # used : true
   # not used : false
   # never used : any
   # incomplete : any
   #
   # wf_status = Indexed
   #

   global assocStatusKey

   wf_status_bcp = open('wf_status_indexed.bcp', 'w+')

   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where exists (select 1 from MGI_Reference_Allele_View gi where gi._Refs_key = r._Refs_key)
	order by r.jnumID
	''' % (apKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], indexedKey, currentDate, currentDate))
	assocStatusKey += 1

   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where ((exists (select 1 from GXD_Index gi where gi._Refs_key = r._Refs_key)
       	  or exists (select 1 from GXD_Assay ga where ga._Refs_key = r._Refs_key)))
	order by r.jnumID
	''' % (gxdKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], indexedKey, currentDate, currentDate))
	assocStatusKey += 1

   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where exists (select 1 from VOC_Evidence e, VOC_Annot a
           where e._Refs_key = r._Refs_key
	   and e._Annot_key = a._Annot_key
	   and a._AnnotType_key = 1000)
	order by r.jnumID
	''' % (goKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], indexedKey, currentDate, currentDate))
	assocStatusKey += 1

   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where exists (select 1 from MLD_Expts gi where gi._Refs_key = r._Refs_key
           and gi.exptType in ('TEXT', 'TEXT-QTL', 'TEXT-QTL-Candidate Genes', 'TEXT-Congenic', 'TEXT-Meta Analysis'))
	order by r.jnumID
	''' % (qtlKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], indexedKey, currentDate, currentDate))
	assocStatusKey += 1

   wf_status_bcp.close()

#
# ap/gxd/go/qtl : chosen
#
def apgxdgoqtl_chosen():
   #
   # selected : true
   # used : false
   # not used : true
   # never used : false
   # incomplete : any
   #
   # wf_status = Chosen
   #

   global assocStatusKey

   wf_status_bcp = open('wf_status_chosen.bcp', 'w+')

   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r, BIB_DataSet_Assoc dbsa
        where dbsa._DataSet_key in (1002)
	and dbsa._Refs_key = r._Refs_key
	and dbsa.isNeverUsed = 0
        and not exists (select 1 from MGI_Reference_Allele_View gi where gi._Refs_key = dbsa._Refs_key)
	order by r.jnumID
	''' % (apKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], chosenKey, currentDate, currentDate))
	assocStatusKey += 1

   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r, BIB_DataSet_Assoc dbsa
        where dbsa._DataSet_key in (1004)
	and dbsa._Refs_key = r._Refs_key
	and dbsa.isNeverUsed = 0
        and not ((exists (select 1 from GXD_Index gi where gi._Refs_key = r._Refs_key)
       	  or exists (select 1 from GXD_Assay ga where ga._Refs_key = r._Refs_key)))
	order by r.jnumID
	''' % (gxdKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], chosenKey, currentDate, currentDate))
	assocStatusKey += 1

   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r, BIB_DataSet_Assoc dbsa
        where dbsa._DataSet_key in (1005)
	and dbsa._Refs_key = r._Refs_key
	and dbsa.isNeverUsed = 0
        and not exists (select 1 from VOC_Evidence e, VOC_Annot a
           where e._Refs_key = r._Refs_key
	   and e._Annot_key = a._Annot_key
	   and a._AnnotType_key = 1000)
	order by r.jnumID
	''' % (goKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], chosenKey, currentDate, currentDate))
	assocStatusKey += 1

   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r, BIB_DataSet_Assoc dbsa
        where dbsa._DataSet_key in (1011)
	and dbsa._Refs_key = r._Refs_key
	and dbsa.isNeverUsed = 0
        and not exists (select 1 from MLD_Expts gi where gi._Refs_key = r._Refs_key
           and gi.exptType in ('TEXT', 'TEXT-QTL', 'TEXT-QTL-Candidate Genes', 'TEXT-Congenic', 'TEXT-Meta Analysis'))
	order by r.jnumID
	''' % (qtlKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], chosenKey, currentDate, currentDate))
	assocStatusKey += 1

   wf_status_bcp.close()

#
# ap/gxd/go/qtl : rejected
#
def apgxdgoqtl_rejected():
   #
   # selected : false
   # used : false
   # not used : any
   # never used : any
   # incomplete : any
   #
   # wf_status = Rejected
   #

   global assocStatusKey

   wf_status_bcp = open('wf_status_rejected.bcp', 'w+')

   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where not exists (select 1 from BIB_DataSet_Assoc dbsa
            where dbsa._dataset_key in (1002)
	    and r._Refs_key = dbsa._Refs_key
	    )
	and not exists (select 1 from MGI_Reference_Allele_View gi where gi._Refs_key = r._Refs_key)
	order by r.jnumID
	''' % (apKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], rejectedKey, currentDate, currentDate))
	assocStatusKey += 1

   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where not exists (select 1 from BIB_DataSet_Assoc dbsa
            where dbsa._dataset_key in (1004)
	    and r._Refs_key = dbsa._Refs_key
	    )
        and not ((exists (select 1 from GXD_Index gi where gi._Refs_key = r._Refs_key)
       	  or exists (select 1 from GXD_Assay ga where ga._Refs_key = r._Refs_key)))
	order by r.jnumID
	''' % (gxdKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], rejectedKey, currentDate, currentDate))
	assocStatusKey += 1

   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where not exists (select 1 from BIB_DataSet_Assoc dbsa
            where dbsa._dataset_key in (1005)
	    and r._Refs_key = dbsa._Refs_key
	    )
        and not exists (select 1 from VOC_Evidence e, VOC_Annot a
           where e._Refs_key = r._Refs_key
	   and e._Annot_key = a._Annot_key
	   and a._AnnotType_key = 1000)
	order by r.jnumID
	''' % (goKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], rejectedKey, currentDate, currentDate))
	assocStatusKey += 1

   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where not exists (select 1 from BIB_DataSet_Assoc dbsa
            where dbsa._dataset_key in (1011)
	    and r._Refs_key = dbsa._Refs_key
	    )
        and not exists (select 1 from MLD_Expts gi where gi._Refs_key = r._Refs_key
           and gi.exptType in ('TEXT', 'TEXT-QTL', 'TEXT-QTL-Candidate Genes', 'TEXT-Congenic', 'TEXT-Meta Analysis'))
	order by r.jnumID
	''' % (qtlKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], rejectedKey, currentDate, currentDate))
	assocStatusKey += 1

   wf_status_bcp.close()

#
# ap/Rejected
#
def ap_rejected():
   #
   # selected : any
   # used : false
   # not used : any
   # never used : true
   # incomplete : any
   #
   # wf_status = Rejected
   #

   global assocStatusKey

   wf_status_bcp = open('wf_status_rejected.bcp', 'w+')

   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where exists (select 1 from BIB_DataSet_Assoc dbsa
            where dbsa._dataset_key in (1002)
	    and r._Refs_key = dbsa._Refs_key
	    and dbsa.isNeverUsed = 1
	    )
	and not exists (select 1 from MGI_Reference_Allele_View gi where gi._Refs_key = r._Refs_key)
	order by r.jnumID
	''' % (apKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], rejectedKey, currentDate, currentDate))
	assocStatusKey += 1

   wf_status_bcp.close()

#
# ap/AP:Incomplete
#
def ap_incomplete():
   #
   # selected : any
   # used : any
   # not used : any
   # never used : any
   # incomplete : true
   #
   # wf_tag = AP:Incomplete
   #

   global assocTagKey

   wf_tag_bcp = open('wf_tag_apincomplete.bcp', 'w+')

   tagKey = db.sql('''
   select t._Term_key from VOC_Vocab v, VOC_Term t 
   where v.name = 'Workflow Tag' and v._Vocab_key = t._Vocab_key and t.term = 'AP:Incomplete'
   ''')[0]['_Term_key']

   querySQL = '''
        select distinct r._Refs_key, r.jnumID
        from BIB_Citation_Cache r
        where exists (select 1 from BIB_DataSet_Assoc dbsa
            where dbsa._dataset_key in (1002)
	    and r._Refs_key = dbsa._Refs_key
	    and dbsa.isIncomplete = 1
	    )
	order by r.jnumID
	'''
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_tag_bcp.write(wf_tag % (assocTagKey, r['_Refs_key'], tagKey, currentDate, currentDate))
	assocTagKey += 1

   wf_tag_bcp.close()

#
# gxd/GXD:Loads
#
def gxd_loads():
   #
   # selected : any
   # used : false
   # not used : any
   # never used : true
   # incomplete : any
   #
   # wf_tag = GXD:Loads
   #

   global assocTagKey

   wf_tag_bcp = open('wf_tag_gxdloads.bcp', 'w+')

   tagKey = db.sql('''
   select t._Term_key from VOC_Vocab v, VOC_Term t
   where v.name = 'Workflow Tag' and v._Vocab_key = t._Vocab_key and t.term = 'GXD:Loads'
   ''')[0]['_Term_key']

   querySQL = '''
        select distinct r._Refs_key, r.jnumID
        from BIB_Citation_Cache r
        where exists (select 1 from BIB_DataSet_Assoc dbsa
            where dbsa._dataset_key in (1004)
            and r._Refs_key = dbsa._Refs_key
            and dbsa.isNeverUsed = 1
            )
        and not ((exists (select 1 from GXD_Index gi where gi._Refs_key = r._Refs_key)
       	  or exists (select 1 from GXD_Assay ga where ga._Refs_key = r._Refs_key)))
        order by r.jnumID
        '''
   results = db.sql(querySQL, 'auto')
   for r in results:
        wf_tag_bcp.write(wf_tag % (assocTagKey, r['_Refs_key'], tagKey, currentDate, currentDate))
        assocTagKey += 1

   wf_tag_bcp.close()

#
# Main
#

db.useOneConnection(1)

assocStatusKey = 1
assocTagKey = 1

apKey = db.sql('''
select t._Term_key from VOC_Vocab v, VOC_Term t 
where v.name = 'Workflow Group' and v._Vocab_key = t._Vocab_key and t.term = 'Alleles & Phenotypes'
''')[0]['_Term_key']

gxdKey = db.sql('''
select t._Term_key from VOC_Vocab v, VOC_Term t 
where v.name = 'Workflow Group' and v._Vocab_key = t._Vocab_key and t.term = 'Expression'
''')[0]['_Term_key']

goKey = db.sql('''
select t._Term_key from VOC_Vocab v, VOC_Term t 
where v.name = 'Workflow Group' and v._Vocab_key = t._Vocab_key and t.term = 'Gene Ontology'
''')[0]['_Term_key']

qtlKey = db.sql('''
select t._Term_key from VOC_Vocab v, VOC_Term t 
where v.name = 'Workflow Group' and v._Vocab_key = t._Vocab_key and t.term = 'QTL'
''')[0]['_Term_key']

indexedKey = db.sql('''
select t._Term_key from VOC_Vocab v, VOC_Term t 
where v.name = 'Workflow Status' and v._Vocab_key = t._Vocab_key and t.term = 'Indexed'
''')[0]['_Term_key']

chosenKey = db.sql('''
select t._Term_key from VOC_Vocab v, VOC_Term t 
where v.name = 'Workflow Status' and v._Vocab_key = t._Vocab_key and t.term = 'Chosen'
''')[0]['_Term_key']

rejectedKey = db.sql('''
select t._Term_key from VOC_Vocab v, VOC_Term t 
where v.name = 'Workflow Status' and v._Vocab_key = t._Vocab_key and t.term = 'Rejected'
''')[0]['_Term_key']

#
# ap/gxd/go/qtl
# Indexed, Chosen, Rejected
#
#apgxdgoqtl_indexed()
#apgxdgoqtl_chosen()
#apgxdgoqtl_rejected()

#
# ap/Rejected
#
#ap_rejected()

#
# ap/AP:Incomplete
#
ap_incomplete()

#
# gxd/GXD:Loads
#
gxd_loads()

#
# go/Rejected
#

#
# Tumor
# Indexed, Rejected, Fully coded
#

#inFile = open('', 'r')
#lineNum = 0
#for line in inFile.readlines():
#	lineNum = lineNum + 1
#	tokens = line[:-1].split('|')

db.useOneConnection(0)

