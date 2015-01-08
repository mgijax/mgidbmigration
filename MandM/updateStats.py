#!/usr/local/bin/python

import sys
import os
import string
import db
import reportlib
import stats
import time

startTime = time.time()

def report (s):
	print 'updateStats.py : %8.3f sec : %s' % (time.time() - startTime, s)
	return

#
#  Set up a connection to the mgd database.
#
dbServer = os.environ['MGD_DBSERVER']
dbName = os.environ['MGD_DBNAME']
user = os.environ['MGD_DBUSER']
passwordFileName = os.environ['MGD_DBPASSWORDFILE']
db.useOneConnection(1)
db.set_sqlUser(user)
db.set_sqlPasswordFromFile(passwordFileName)
stats.setSqlFunction(db.sql)

report('Set up database connection')

HOMOLOGENE = 9272151
HOMOLOGY = 9272150

# We're going to replace the various statistics involving n-to-m homologies
# to ensure that they only count clusters from HomoloGene.  We will leave the
# old measurements in place.

# Each statistic defined as (abbreviation, name, definition, SQL) -- we assume
# that each is not private and that each has an integer value.  Ordering of
# statistics for display is implied here.  For simplicity (and since it's not
# displayed anywhere, we have the definition often be the same as the name).
newStats = [
	('homologyPCG',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm,
			MRK_Cluster mc
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = %d
			and mc._ClusterType_key = %d''' % (HOMOLOGENE,
				HOMOLOGY) ),

	('homologyHuman',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = %d
			and mc._ClusterType_key = %d
			and exists (select 1
				from MRK_ClusterMember ocm, MGI_Organism mo,
					MRK_Marker om, MRK_Cluster oc
				where mc._Cluster_key = ocm._Cluster_key
				and ocm._Cluster_key = oc._Cluster_key
				and oc._ClusterSource_key = %d
				and oc._ClusterType_key = %d
				and ocm._Marker_key = om._Marker_key
				and om._Organism_key = mo._Organism_key
				and mo.commonName = 'human') ''' % (
					HOMOLOGENE, HOMOLOGY,
					HOMOLOGENE, HOMOLOGY) ),

	('homologyHumanOneToOne',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc, MRK_ClusterMember ocm,
			MGI_Organism mo, MRK_Marker om
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = %d
			and mc._ClusterType_key = %d
			and mc._Cluster_key = ocm._Cluster_key
			and ocm._Marker_key = om._Marker_key
			and om._Organism_key = mo._Organism_key
			and mo.commonName = 'human'
			and not exists (select 1
				from MRK_ClusterMember ocm2, MGI_Organism mo2,
					MRK_Marker om2, MRK_Cluster oc2
				where mc._Cluster_key = ocm2._Cluster_key
				and ocm2._Cluster_key = oc2._Cluster_key
				and oc2._ClusterSource_key = %d
				and oc2._ClusterType_key = %d
				and ocm2._Marker_key = om2._Marker_key
				and om2._Organism_key = mo2._Organism_key
				and mo2.commonName = 'human'
				and om2._Marker_key != om._Marker_key)
			and not exists (select 1
				from MRK_ClusterMember mcm2, MRK_Marker m2,
					MRK_Cluster mc2
				where mc._Cluster_key = mcm2._Cluster_key
				and mcm2._Cluster_key = mc2._Cluster_key
				and mc2._ClusterSource_key = %d
				and mc2._ClusterType_key = %d
				and mcm2._Marker_key = m2._Marker_key
				and m2._Organism_key = 1
				and m2._Marker_key != m._Marker_key)''' % (
					HOMOLOGENE, HOMOLOGY,
					HOMOLOGENE, HOMOLOGY,
					HOMOLOGENE, HOMOLOGY) ),

	('homologyRat',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = %d
			and mc._ClusterType_key = %d
			and exists (select 1
				from MRK_ClusterMember ocm, MGI_Organism mo,
					MRK_Marker om, MRK_Cluster oc
				where mc._Cluster_key = ocm._Cluster_key
				and ocm._Cluster_key = oc._Cluster_key
				and oc._ClusterSource_key = %d
				and oc._ClusterType_key = %d
				and ocm._Marker_key = om._Marker_key
				and om._Organism_key = mo._Organism_key
				and mo.commonName = 'rat')''' % (
					HOMOLOGENE, HOMOLOGY,
					HOMOLOGENE, HOMOLOGY) ),

	('homologyChimp',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = %d
			and mc._ClusterType_key = %d
			and exists (select 1
				from MRK_ClusterMember ocm, MGI_Organism mo,
					MRK_Marker om, MRK_Cluster oc
				where mc._Cluster_key = ocm._Cluster_key
				and ocm._Cluster_key = oc._Cluster_key
				and oc._ClusterSource_key = %d
				and oc._ClusterType_key = %d
				and ocm._Marker_key = om._Marker_key
				and om._Organism_key = mo._Organism_key
				and mo.commonName = 'chimpanzee')''' % (
					HOMOLOGENE, HOMOLOGY,
					HOMOLOGENE, HOMOLOGY) ),

	('homologyMonkey',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = %d
			and mc._ClusterType_key = %d
			and exists (select 1
				from MRK_ClusterMember ocm, MGI_Organism mo,
					MRK_Marker om, MRK_Cluster oc
				where mc._Cluster_key = ocm._Cluster_key
				and ocm._Cluster_key = oc._Cluster_key
				and oc._ClusterSource_key = %d
				and oc._ClusterType_key = %d
				and ocm._Marker_key = om._Marker_key
				and om._Organism_key = mo._Organism_key
				and mo.commonName = 'rhesus macaque')''' % (
					HOMOLOGENE, HOMOLOGY,
					HOMOLOGENE, HOMOLOGY) ),

	('homologyDog',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = %d
			and mc._ClusterType_key = %d
			and exists (select 1
				from MRK_ClusterMember ocm, MGI_Organism mo,
					MRK_Marker om, MRK_Cluster oc
				where mc._Cluster_key = ocm._Cluster_key
				and ocm._Cluster_key = oc._Cluster_key
				and oc._ClusterSource_key = %d
				and oc._ClusterType_key = %d
				and ocm._Marker_key = om._Marker_key
				and om._Organism_key = mo._Organism_key
				and mo.commonName = 'dog, domestic')''' % (
					HOMOLOGENE, HOMOLOGY,
					HOMOLOGENE, HOMOLOGY) ),

	('homologyCattle',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = %d
			and mc._ClusterType_key = %d
			and exists (select 1
				from MRK_ClusterMember ocm, MGI_Organism mo,
					MRK_Marker om, MRK_Cluster oc
				where mc._Cluster_key = ocm._Cluster_key
				and ocm._Cluster_key = oc._Cluster_key
				and oc._ClusterSource_key = %d
				and oc._ClusterType_key = %d
				and ocm._Marker_key = om._Marker_key
				and om._Organism_key = mo._Organism_key
				and mo.commonName = 'cattle')''' % (
					HOMOLOGENE, HOMOLOGY,
					HOMOLOGENE, HOMOLOGY) ),

	('homologyChicken',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = %d
			and mc._ClusterType_key = %d
			and exists (select 1
				from MRK_ClusterMember ocm, MGI_Organism mo,
					MRK_Marker om, MRK_Cluster oc
				where mc._Cluster_key = ocm._Cluster_key
				and ocm._Cluster_key = oc._Cluster_key
				and oc._ClusterSource_key = %d
				and oc._ClusterType_key = %d
				and ocm._Marker_key = om._Marker_key
				and om._Organism_key = mo._Organism_key
				and mo.commonName = 'chicken')''' % (
					HOMOLOGENE, HOMOLOGY,
					HOMOLOGENE, HOMOLOGY) ),

	('homologyZebrafish',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = %d
			and mc._ClusterType_key = %d
			and exists (select 1
				from MRK_ClusterMember ocm, MGI_Organism mo,
					MRK_Marker om, MRK_Cluster oc
				where mc._Cluster_key = ocm._Cluster_key
				and ocm._Cluster_key = oc._Cluster_key
				and oc._ClusterSource_key = %d
				and oc._ClusterType_key = %d
				and ocm._Marker_key = om._Marker_key
				and om._Organism_key = mo._Organism_key
				and mo.commonName = 'zebrafish')''' % (
					HOMOLOGENE, HOMOLOGY,
					HOMOLOGENE, HOMOLOGY) ),

	]

# create the statistic records in the database

for (abbrev, sql) in newStats:

	# 0 = not private; 1 = has integer value
	stat = stats.getStatistic (abbrev)
	stat.setSql(sql)

report ('Updated Statistic records')

# now compute new measurements to ensure that the new statistics have one.
# SKIP THIS AS THE MIGRATION ALREADY DOES THIS IN PART 3.
#stats.measureAllHavingSql()
#report ('Computed new measurements')

db.useOneConnection(0)

report ('Finished')
