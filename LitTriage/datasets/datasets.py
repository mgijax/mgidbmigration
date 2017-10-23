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

#db.setTrace()

wf_status = '%s|%s|%s|%s|1|1001|1001|%s|%s\n'

wf_tag = '%s|%s|%s|1001|1001|%s|%s\n'

currentDate = mgi_utils.date('%m/%d/%Y')

assocStatusKey = 1
assocTagKey = 1

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

   #
   # in MGI_Reference_Assoc
   # not in MP annot
   #
   querySQL = '''
	(
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where exists (select 1 from MGI_Reference_Assoc gi where gi._Refs_key = r._Refs_key and gi._MGIType_key = 11)
        and not exists (select 1 from VOC_Evidence e, VOC_Annot a
           where e._Refs_key = r._Refs_key
           and e._Annot_key = a._Annot_key
           and a._AnnotType_key = 1002)
        )
	order by r.jnumID
	''' % (apKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], indexedKey, currentDate, currentDate))
	assocStatusKey += 1
   print 'Allele/Pheno | INDEXED | used | %d\n' % (len(results))

   #
   # gxd : gxd_index and not in gxd_assay
   #
   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where exists (select 1 from GXD_Index gi where gi._Refs_key = r._Refs_key)
	and not exists (select 1 from GXD_Assay ga where ga._Refs_key = r._Refs_key
		and ga._AssayType_key in (1,2,3,4,5,6,8,9))
		)
	''' % (gxdKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], indexedKey, currentDate, currentDate))
	assocStatusKey += 1
   print 'Expression   | INDEXED | used | %d\n' % (len(results))

   #
   # no annotations
   # marker is indexed
   #
   querySQL = '''
	(
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r, BIB_DataSet_Assoc dbsa
        where dbsa._DataSet_key in (1005)
	and dbsa._Refs_key = r._Refs_key
	and dbsa.isNeverUsed = 0
        and not exists (select 1 from VOC_Evidence e, VOC_Annot a
           where e._Refs_key = r._Refs_key
	   and e._Annot_key = a._Annot_key
	   and a._AnnotType_key = 1000)
	and exists (select 1 from MGI_Reference_Assoc gi where gi._Refs_key = r._Refs_key and gi._MGIType_key = 2)
	)
	order by jnumID
	''' % (goKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], indexedKey, currentDate, currentDate))
	assocStatusKey += 1
   print 'GO           | INDEXED | used | %d\n' % (len(results))

   #
   # no Mapping
   # QTL marker
   #
   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where not exists (select 1 from MLD_Expts gi where gi._Refs_key = r._Refs_key
           and gi.exptType in ('TEXT', 'TEXT-QTL', 'TEXT-QTL-Candidate Genes', 'TEXT-Congenic', 'TEXT-Meta Analysis'))
        and exists (select 1 from MRK_Reference gi, MRK_Marker m
                where gi._Refs_key = r._Refs_key
		and gi._Marker_key = m._Marker_key
                and m._Marker_Type_key = 6)
	order by r.jnumID
	''' % (qtlKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], indexedKey, currentDate, currentDate))
	assocStatusKey += 1
   print 'QTL          | INDEXED | used | %d\n' % (len(results))

   wf_status_bcp.close()

#
# ap/gxd/go : chosen
#
def apgxdgo_chosen():
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
        and not exists (select 1 from MGI_Reference_Assoc gi where gi._Refs_key = r._Refs_key and gi._MGIType_key = 11)
        and not exists (select 1 from VOC_Evidence e, VOC_Annot a
           where e._Refs_key = r._Refs_key
           and e._Annot_key = a._Annot_key
           and a._AnnotType_key = 1002)
	order by r.jnumID
	''' % (apKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], chosenKey, currentDate, currentDate))
	assocStatusKey += 1
   print 'Allele/Pheno | CHOSEN | selected/not used | %d\n' % (len(results))

   querySQL = '''
	(
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r, BIB_DataSet_Assoc dbsa
        where dbsa._DataSet_key in (1004)
	and dbsa._Refs_key = r._Refs_key
	and dbsa.isNeverUsed = 0
        and not ((exists (select 1 from GXD_Index gi where gi._Refs_key = r._Refs_key)
       	  or exists (select 1 from GXD_Assay ga where ga._Refs_key = r._Refs_key
		and ga._AssayType_key in (1,2,3,4,5,6,8,9))))
	union
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
	where r._Refs_key in (82826,154970,162862,178645,202491)
	)
	order by jnumID
	''' % (gxdKey, gxdKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], chosenKey, currentDate, currentDate))
	assocStatusKey += 1
   print 'Expression   | CHOSEN | selected/not used | %d\n' % (len(results))

   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r, BIB_DataSet_Assoc dbsa
        where dbsa._DataSet_key in (1005)
	and dbsa._Refs_key = r._Refs_key
	and dbsa.isNeverUsed = 0
	and not exists (select 1 from MGI_Reference_Assoc gi where gi._Refs_key = r._Refs_key and gi._MGIType_key = 2)
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
   print 'GO           | CHOSEN | selected/not used | %d\n' % (len(results))

   wf_status_bcp.close()

#
# qtl : routed
#
def qtl_routed():
   #
   # selected : true
   # used : false
   # not used : true
   # never used : false
   # incomplete : any
   #
   # wf_status = Routed
   #

   global assocStatusKey

   wf_status_bcp = open('wf_status_routed.bcp', 'w+')

   #
   # selected, no Mapping
   #

   querySQL = '''
	(
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r, BIB_DataSet_Assoc dbsa
        where dbsa._DataSet_key in (1011)
	and dbsa._Refs_key = r._Refs_key
	and dbsa.isNeverUsed = 0
        and not exists (select 1 from MLD_Expts gi where gi._Refs_key = r._Refs_key
           and gi.exptType in ('TEXT', 'TEXT-QTL', 'TEXT-QTL-Candidate Genes', 'TEXT-Congenic', 'TEXT-Meta Analysis'))
        and not exists (select 1 from MRK_Reference gi, MRK_Marker m
                where gi._Refs_key = r._Refs_key
		and gi._Marker_key = m._Marker_key
                and m._Marker_Type_key = 6)
	)
	order by jnumID
	''' % (qtlKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], routedKey, currentDate, currentDate))
	assocStatusKey += 1
   print 'QTL          | ROUTED | selected/not used | %d\n' % (len(results))

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
        and not exists (select 1 from MGI_Reference_Assoc gi where gi._Refs_key = r._Refs_key and gi._MGIType_key = 11)
        and not exists (select 1 from VOC_Evidence e, VOC_Annot a
           where e._Refs_key = r._Refs_key
           and e._Annot_key = a._Annot_key
           and a._AnnotType_key = 1002)
	order by r.jnumID
	''' % (apKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], rejectedKey, currentDate, currentDate))
	assocStatusKey += 1
   print 'Allele/Pheno | REJECTED | not selected/not used | %d\n' % (len(results))

   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where not exists (select 1 from BIB_DataSet_Assoc dbsa
            where dbsa._dataset_key in (1004)
	    and r._Refs_key = dbsa._Refs_key
	    )
        and not ((exists (select 1 from GXD_Index gi where gi._Refs_key = r._Refs_key)
       	  or exists (select 1 from GXD_Assay ga where ga._Refs_key = r._Refs_key
		and ga._AssayType_key in (1,2,3,4,5,6,8,9))))
	order by r.jnumID
	''' % (gxdKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], rejectedKey, currentDate, currentDate))
	assocStatusKey += 1
   print 'Expression   | REJECTED | not selected/not used | %d\n' % (len(results))

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
   print 'GO           | REJECTED | not selected/not used | %d\n' % (len(results))

   #
   # AP-only Rejected
   #
   # selected : any
   # used : false
   # not used : any
   # never used : true
   # incomplete : any
   #

   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where exists (select 1 from BIB_DataSet_Assoc dbsa
            where dbsa._dataset_key in (1002)
	    and r._Refs_key = dbsa._Refs_key
	    and dbsa.isNeverUsed = 1
	    )
        and not exists (select 1 from MGI_Reference_Assoc gi where gi._Refs_key = r._Refs_key and gi._MGIType_key = 11)
        and not exists (select 1 from VOC_Evidence e, VOC_Annot a
           where e._Refs_key = r._Refs_key
           and e._Annot_key = a._Annot_key
           and a._AnnotType_key = 1002)
	order by r.jnumID
	''' % (apKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], rejectedKey, currentDate, currentDate))
	assocStatusKey += 1
   print 'Allele/Pheno | REJECTED | not used | never used | %d\n' % (len(results))

   #
   # GO-only Rejected
   #
   # selected : any
   # used : false
   # not used : any
   # never used : true
   # incomplete : any
   #

   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where exists (select 1 from BIB_DataSet_Assoc dbsa
            where dbsa._dataset_key in (1005)
	    and r._Refs_key = dbsa._Refs_key
	    and dbsa.isNeverUsed = 1
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
   print 'GO           | REJECTED | not used | never used | %d\n' % (len(results))

   #
   # QTL-only Rejected
   #
   # selected : false
   # used : false
   # not used : any
   # never used : any
   # incomplete : any
   #
   querySQL = '''
	(
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where not exists (select 1 from BIB_DataSet_Assoc dbsa
            where dbsa._dataset_key in (1011)
	    and r._Refs_key = dbsa._Refs_key
	    )
        and not exists (select 1 from MLD_Expts gi where gi._Refs_key = r._Refs_key
           and gi.exptType in ('TEXT', 'TEXT-QTL', 'TEXT-QTL-Candidate Genes', 'TEXT-Congenic', 'TEXT-Meta Analysis'))
        and not exists (select 1 from MRK_Reference gi, MRK_Marker m
                 where gi._Refs_key = r._Refs_key
		 and gi._Marker_key = m._Marker_key
		 and m._Marker_Type_key = 6)
	)
	order by jnumID
	''' % (qtlKey,)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], rejectedKey, currentDate, currentDate))
	assocStatusKey += 1
   print 'QTL          | REJECTED | not selected/not used | %d\n' % (len(results))

   #
   # selected : any
   # used : false
   # not used : any
   # never used : true
   # incomplete : any
   #

   querySQL = '''
	(
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where exists (select 1 from BIB_DataSet_Assoc dbsa
            where dbsa._dataset_key in (1011)
	    and r._Refs_key = dbsa._Refs_key
	    and dbsa.isNeverUsed = 1
	    )
        and not exists (select 1 from MLD_Expts gi where gi._Refs_key = r._Refs_key
           and gi.exptType in ('TEXT', 'TEXT-QTL', 'TEXT-QTL-Candidate Genes', 'TEXT-Congenic', 'TEXT-Meta Analysis'))
        and not exists (select 1 from MRK_Reference gi, MRK_Marker m
                 where gi._Refs_key = r._Refs_key
		 and gi._Marker_key = m._Marker_key
		 and m._Marker_Type_key = 6)
	)
	order by jnumID
	''' % (qtlKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], rejectedKey, currentDate, currentDate))
	assocStatusKey += 1
   print 'QTL           | REJECTED | not used | never used | %d\n' % (len(results))

   # exists Mapping
   # marker is not QTL
   #

   querySQL = '''
	(
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where exists (select 1 from MLD_Expts gi where gi._Refs_key = r._Refs_key
           and gi.exptType in ('TEXT', 'TEXT-QTL', 'TEXT-QTL-Candidate Genes', 'TEXT-Congenic', 'TEXT-Meta Analysis'))
        and not exists (select 1 from MLD_Expts gi, MLD_Expt_Marker mi, MRK_Marker m
                where gi._Refs_key = r._Refs_key
                and gi._Expt_key = mi._Expt_key
                and mi._Marker_key = m._Marker_key
                and m._Marker_Type_key = 6)
	)
	order by jnumID
	''' % (qtlKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], rejectedKey, currentDate, currentDate))
	assocStatusKey += 1
   print 'QTL           | REJECTED | used in mapping | no QTL marker | %d\n' % (len(results))

   wf_status_bcp.close()

#
# ap/gxd/go/qtl : full-coded
#
def apgxdgoqtl_fullcoded():
   #   
   # wf_status = Full-coded
   #   

   global assocStatusKey

   wf_status_bcp = open('wf_status_fullcoded.bcp', 'w+')

   #
   # in MP annotation
   #
   querySQL = '''
	(
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where exists (select 1 from VOC_Evidence e, VOC_Annot a
           where e._Refs_key = r._Refs_key
           and e._Annot_key = a._Annot_key
           and a._AnnotType_key = 1002)
        )
	order by jnumID
	''' % (apKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], curatedKey, currentDate, currentDate))
	assocStatusKey += 1
   print 'Allele/Pheno | FULL-CODED | used | %d\n' % (len(results))

   #
   # in GXD_Assay
   #
   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where exists (select 1 from GXD_Assay ga where ga._Refs_key = r._Refs_key
		and ga._AssayType_key in (1,2,3,4,5,6,8,9))
	''' % (gxdKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], curatedKey, currentDate, currentDate))
	assocStatusKey += 1
   print 'Expression   | FULL-CODED | used | %d\n' % (len(results))

   #
   # in GO annotation
   #
   querySQL = ''' 
        (
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where exists (select 1 from VOC_Evidence e, VOC_Annot a
           where e._Refs_key = r._Refs_key
           and e._Annot_key = a._Annot_key
           and a._AnnotType_key = 1000)
        )
        order by jnumID
        ''' % (goKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
        wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], curatedKey, currentDate, currentDate))
        assocStatusKey += 1
   print 'GO           | FULL-CODED | used | %d\n' % (len(results))

   #
   # Mapping
   # QTL marker
   #
   querySQL = '''
        select distinct r._Refs_key, r.jnumID, %s as groupKey
        from BIB_Citation_Cache r
        where exists (select 1 from MLD_Expts gi where gi._Refs_key = r._Refs_key
           and gi.exptType in ('TEXT', 'TEXT-QTL', 'TEXT-QTL-Candidate Genes', 'TEXT-Congenic', 'TEXT-Meta Analysis'))
        and exists (select 1 from MLD_Expts gi, MLD_Expt_Marker mi, MRK_Marker m
                where gi._Refs_key = r._Refs_key
                and gi._Expt_key = mi._Expt_key
                and mi._Marker_key = m._Marker_key
                and m._Marker_Type_key = 6)
	order by r.jnumID
	''' % (qtlKey)
   results = db.sql(querySQL, 'auto')
   for r in results:
   	wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], r['groupKey'], curatedKey, currentDate, currentDate))
	assocStatusKey += 1
   print 'QTL          | FULL-CODED | used | %d\n' % (len(results))

#
# ap/AP:Incomplete
#
def ap_tag():
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

   wf_tag_bcp = open('wf_tag_ap.bcp', 'w+')

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
   	wf_tag_bcp.write(wf_tag % (assocTagKey, r['_Refs_key'], 31576705, currentDate, currentDate))
	assocTagKey += 1
   print 'Allele/Pheno | AP:Incomplete | incomplete | %d\n' % (len(results))

   #
   # selected : true
   # used : na
   # not used : na
   # never used : na
   # incomplete : na
   #
   # wf_tag = AP:strain
   #

   querySQL = '''
        select distinct r._Refs_key, r.jnumID
        from BIB_Citation_Cache r
        where exists (select 1 from BIB_DataSet_Assoc dbsa
            where dbsa._dataset_key in (1008)
            and r._Refs_key = dbsa._Refs_key
            )
        order by r.jnumID
        '''
   results = db.sql(querySQL, 'auto')
   for r in results:
        wf_tag_bcp.write(wf_tag % (assocTagKey, r['_Refs_key'], 31576694, currentDate, currentDate))
        assocTagKey += 1
   print 'SCC          | AP:strains | selected | %d\n' % (len(results))

   wf_tag_bcp.close()

# gxd/GXD:Loads
#
def gxd_tag():
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

   wf_tag_bcp = open('wf_tag_gxd.bcp', 'w+')

   querySQL = '''
        select distinct r._Refs_key, r.jnumID
        from BIB_Citation_Cache r
        where exists (select 1 from BIB_DataSet_Assoc dbsa
            where dbsa._dataset_key in (1004)
            and r._Refs_key = dbsa._Refs_key
            and dbsa.isNeverUsed = 1
            )
        and not ((exists (select 1 from GXD_Index gi where gi._Refs_key = r._Refs_key)
       	  or exists (select 1 from GXD_Assay ga where ga._Refs_key = r._Refs_key
		and ga._AssayType_key in (1,2,3,4,5,6,8,9))))
        order by r.jnumID
        '''
   results = db.sql(querySQL, 'auto')
   for r in results:
        wf_tag_bcp.write(wf_tag % (assocTagKey, r['_Refs_key'], 31576733, currentDate, currentDate))
        assocTagKey += 1
   print 'GXD          | GXD:Loads | not used | never used | %d\n' % (len(results))

   wf_tag_bcp.close()

#
# probe, mapping, nomen, markers, PRO tags
#
def other_tags():
   #
   # selected : any
   # used : true
   # not used : any
   # never used : any
   # incomplete : any
   #
   # wf_tag = MGI:probes
   #

   global assocTagKey

   wf_tag_bcp = open('wf_tag.bcp', 'w+')

   querySQL = '''
        select distinct r._Refs_key, r.jnumID
        from BIB_Citation_Cache r
        where exists (select 1 from PRB_Reference gi where gi._Refs_key = r._Refs_key)
        order by r.jnumID
        '''
   results = db.sql(querySQL, 'auto')
   for r in results:
        wf_tag_bcp.write(wf_tag % (assocTagKey, r['_Refs_key'], 31576697, currentDate, currentDate))
        assocTagKey += 1
   print 'Probe | MGI:probe | used | %d\n' % (len(results))

   querySQL = '''
        select distinct r._Refs_key, r.jnumID
        from BIB_Citation_Cache r
        where exists (select 1 from MLD_Expts gi where gi._Refs_key = r._Refs_key)
        order by r.jnumID
        '''
   results = db.sql(querySQL, 'auto')
   for r in results:
        wf_tag_bcp.write(wf_tag % (assocTagKey, r['_Refs_key'], 31576695, currentDate, currentDate))
        assocTagKey += 1
   print 'Mapping | MGI:mapping | used | %d\n' % (len(results))

   #commented out per Monica 10/19/2017
   #querySQL = '''
   #     select distinct r._Refs_key, r.jnumID
   #     from BIB_Citation_Cache r
   #     where exists (select 1 from MGI_Reference_Assoc gi where gi._Refs_key = r._Refs_key and gi._MGIType_key = 2)
   #     order by r.jnumID
   #     '''
   #results = db.sql(querySQL, 'auto')
   #for r in results:
   #     wf_tag_bcp.write(wf_tag % (assocTagKey, r['_Refs_key'], 31576692, currentDate, currentDate))
   #     assocTagKey += 1
   #print 'Nomen | MGI:nomen_used | %d\n' % (len(results))

   querySQL = '''
        select distinct r._Refs_key, r.jnumID
        from BIB_Citation_Cache r, BIB_DataSet_Assoc dbsa
        where dbsa._DataSet_key in (1010,1006)
	and dbsa._Refs_key = r._Refs_key
	and dbsa.isNeverUsed = 0
        and not exists (select 1 from MGI_Reference_Assoc gi where gi._Refs_key = r._Refs_key and gi._MGIType_key = 2)
        order by r.jnumID
        '''
   results = db.sql(querySQL, 'auto')
   for r in results:
        wf_tag_bcp.write(wf_tag % (assocTagKey, r['_Refs_key'], 34693807, currentDate, currentDate))
        assocTagKey += 1
   print 'Nomen | MGI:nomen_selected | %d\n' % (len(results))

   querySQL = '''
        select distinct r._Refs_key, r.jnumID
        from BIB_Citation_Cache r
        where exists (select 1 from MGI_Reference_Assoc gi where gi._Refs_key = r._Refs_key and gi._MGIType_key = 2)
        order by r.jnumID
        '''
   results = db.sql(querySQL, 'auto')
   for r in results:
        wf_tag_bcp.write(wf_tag % (assocTagKey, r['_Refs_key'], 31576696, currentDate, currentDate))
        assocTagKey += 1
   print 'Marker | MGI:markers | used | %d\n' % (len(results))

   querySQL = '''
        select distinct r._Refs_key, r.jnumID
        from BIB_Citation_Cache r
        where exists (select 1 from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p
        	where e._Refs_key = r._Refs_key
        	and a._AnnotType_key = 1000
        	and a._Annot_key = e._Annot_key
        	and e._AnnotEvidence_key = p._AnnotEvidence_key
        	and p._PropertyTerm_key = 6481775
        	)
        order by r.jnumID
        '''
   results = db.sql(querySQL, 'auto')
   for r in results:
        wf_tag_bcp.write(wf_tag % (assocTagKey, r['_Refs_key'], 31576693, currentDate, currentDate))
        assocTagKey += 1
   print 'PRO | MGI:PRO_used | %d\n' % (len(results))

   querySQL = '''
        select distinct r._Refs_key, r.jnumID
        from BIB_Citation_Cache r, BIB_DataSet_Assoc dbsa
        where dbsa._DataSet_key in (1012)
	and dbsa._Refs_key = r._Refs_key
	and dbsa.isNeverUsed = 0
        and not exists (select 1 from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p
        	where e._Refs_key = r._Refs_key
        	and a._AnnotType_key = 1000
        	and a._Annot_key = e._Annot_key
        	and e._AnnotEvidence_key = p._AnnotEvidence_key
        	and p._PropertyTerm_key = 6481775
        	)
        order by r.jnumID
        '''
   results = db.sql(querySQL, 'auto')
   for r in results:
        wf_tag_bcp.write(wf_tag % (assocTagKey, r['_Refs_key'], 34693808, currentDate, currentDate))
        assocTagKey += 1
   print 'PRO | MGI:PRO_selected | %d\n' % (len(results))

   wf_tag_bcp.close()

#
# tumor
#
def tumor_status():

   global assocStatusKey

   wf_status_bcp = open('wf_status_tumor.bcp', 'w+')

   inFile = open('MTB_indexed.txt', 'r')
   counter = 0
   for line in inFile.readlines():
   	tokens = line[:-1]
	jnumID = tokens
	querySQL = '''select distinct _Refs_key from BIB_Citation_Cache where jnumID = '%s' ''' % (jnumID)
   	results = db.sql(querySQL, 'auto')
   	for r in results:
   		wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], tumorKey, indexedKey, currentDate, currentDate))
		assocStatusKey += 1
	        counter += 1
   print 'Tumor           | INDEXED | %d\n' % (counter)
   inFile.close()

   inFile = open('MTB_rejected.txt', 'r')
   counter = 0
   for line in inFile.readlines():
   	tokens = line[:-1].split('\t')
	jnumID = tokens[1]
	querySQL = '''select distinct _Refs_key from BIB_Citation_Cache where jnumID = '%s' ''' % (jnumID)
   	results = db.sql(querySQL, 'auto')
   	for r in results:
   		wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], tumorKey, rejectedKey, currentDate, currentDate))
		assocStatusKey += 1
	        counter += 1
   print 'Tumor           | REJECTED | %d\n' % (counter)
   inFile.close()

   inFile = open('MTB_coded.txt', 'r')
   counter = 0
   for line in inFile.readlines():
   	tokens = line[:-1].split('\t')
	jnumID = tokens[1]
	querySQL = '''select distinct _Refs_key from BIB_Citation_Cache where jnumID = '%s' ''' % (jnumID)
  	results = db.sql(querySQL, 'auto')
   	for r in results:
   		wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], tumorKey, curatedKey, currentDate, currentDate))
		assocStatusKey += 1
	        counter += 1
   print 'Tumor           | FULLY CURATED | %d\n' % (counter)
   inFile.close()

   wf_status_bcp.close()
   
#
# Main
#

db.useOneConnection(1)

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

tumorKey = db.sql('''
select t._Term_key from VOC_Vocab v, VOC_Term t 
where v.name = 'Workflow Group' and v._Vocab_key = t._Vocab_key and t.term = 'Tumor'
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

routedKey = db.sql('''
select t._Term_key from VOC_Vocab v, VOC_Term t 
where v.name = 'Workflow Status' and v._Vocab_key = t._Vocab_key and t.term = 'Routed'
''')[0]['_Term_key']

curatedKey = db.sql('''
select t._Term_key from VOC_Vocab v, VOC_Term t 
where v.name = 'Workflow Status' and v._Vocab_key = t._Vocab_key and t.term = 'Full-coded'
''')[0]['_Term_key']

#
# Status
# ap/gxd/go/qtl
# Indexed, Chosen, Routed, Rejected
#
apgxdgoqtl_indexed()
apgxdgo_chosen()
apgxdgoqtl_fullcoded()
apgxdgoqtl_rejected()
qtl_routed()

# Tags
ap_tag()
gxd_tag()

#
# probe, mapping, nomen, markers, PRO, SCC tags
#
other_tags()

#
# Tumor
# Indexed, Rejected, Fully coded
#
tumor_status()

db.useOneConnection(0)

