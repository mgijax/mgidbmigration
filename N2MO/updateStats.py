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

# We're going to replace the various statistics with new ones based on the
# n-to-m homologies from HomoloGene.  We will leave the old measurements
# in place, however, so we have historical data, and will just remove them
# from the groups so they won't be displayed.

# Each statistic defined as (abbreviation, name, definition, SQL) -- we assume
# that each is not private and that each has an integer value.  Ordering of
# statistics for display is implied here.  For simplicity (and since it's not
# displayed anywhere, we have the definition often be the same as the name).
newStats = [
	('mousePCG',
	'Mouse protein coding genes',
	'Mouse protein coding genes',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m
		where mcv.term = 'protein coding gene'
		and mcv.qualifier = 'D'
		and mcv._Marker_key = m._Marker_key
		and m._Marker_Status_key in (1,3)
		and m._Organism_key = 1'''),

	('homologyPCG',
	'Mouse protein coding genes in homology classes',
	'Mouse protein coding genes in homology classes',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm,
			MRK_Cluster mc, VOC_Term vt
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = vt._Term_key
			and vt.term = 'HomoloGene' '''),

	('homologyHuman',
	'Mouse protein coding genes in homology classes with Human genes',
	'Mouse protein coding genes in homology classes with Human genes',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc, VOC_Term vt
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = vt._Term_key
			and vt.term = 'HomoloGene'
			and exists (select 1
				from MRK_ClusterMember ocm, MGI_Organism mo,
					MRK_Marker om
				where mc._Cluster_key = ocm._Cluster_key
				and ocm._Marker_key = om._Marker_key
				and om._Organism_key = mo._Organism_key
				and mo.commonName = 'human') '''),

	('homologyHumanOneToOne',
	'Mouse protein coding genes in homology classes with one-to-one ' + \
		'correspondence of Mouse and Human genes',
	'Mouse protein coding genes in homology classes with one-to-one ' + \
		'correspondence of Mouse and Human genes',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc, VOC_Term vt, MRK_ClusterMember ocm,
			MGI_Organism mo, MRK_Marker om
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = vt._Term_key
			and vt.term = 'HomoloGene'
			and mc._Cluster_key = ocm._Cluster_key
			and ocm._Marker_key = om._Marker_key
			and om._Organism_key = mo._Organism_key
			and mo.commonName = 'human'
			and not exists (select 1
				from MRK_ClusterMember ocm2, MGI_Organism mo2,
					MRK_Marker om2
				where mc._Cluster_key = ocm2._Cluster_key
				and ocm2._Marker_key = om2._Marker_key
				and om2._Organism_key = mo2._Organism_key
				and mo2.commonName = 'human'
				and om2._Marker_key != om._Marker_key)
			and not exists (select 1
				from MRK_ClusterMember mcm2, MRK_Marker m2
				where mc._Cluster_key = mcm2._Cluster_key
				and mcm2._Marker_key = m2._Marker_key
				and m2._Organism_key = 1
				and m2._Marker_key != m._Marker_key)'''),

	('homologyRat',
	'Mouse protein coding genes in homology classes with Rat genes',
	'Mouse protein coding genes in homology classes with Rat genes',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc, VOC_Term vt
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = vt._Term_key
			and vt.term = 'HomoloGene'
			and exists (select 1
				from MRK_ClusterMember ocm, MGI_Organism mo,
					MRK_Marker om
				where mc._Cluster_key = ocm._Cluster_key
				and ocm._Marker_key = om._Marker_key
				and om._Organism_key = mo._Organism_key
				and mo.commonName = 'rat')'''),

	('homologyChimp',
	'Mouse protein coding genes in homology classes with Chimpanzee genes',
	'Mouse protein coding genes in homology classes with Chimpanzee genes',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc, VOC_Term vt
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = vt._Term_key
			and vt.term = 'HomoloGene'
			and exists (select 1
				from MRK_ClusterMember ocm, MGI_Organism mo,
					MRK_Marker om
				where mc._Cluster_key = ocm._Cluster_key
				and ocm._Marker_key = om._Marker_key
				and om._Organism_key = mo._Organism_key
				and mo.commonName = 'chimpanzee')'''),

	('homologyMonkey',
	'Mouse protein coding genes in homology classes with Rhesus ' + \
		'macaque genes',
	'Mouse protein coding genes in homology classes with Rhesus ' + \
		'macaque genes',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc, VOC_Term vt
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = vt._Term_key
			and vt.term = 'HomoloGene'
			and exists (select 1
				from MRK_ClusterMember ocm, MGI_Organism mo,
					MRK_Marker om
				where mc._Cluster_key = ocm._Cluster_key
				and ocm._Marker_key = om._Marker_key
				and om._Organism_key = mo._Organism_key
				and mo.commonName = 'rhesus macaque')'''),

	('homologyDog',
	'Mouse protein coding genes in homology classes with Dog genes',
	'Mouse protein coding genes in homology classes with Dog genes',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc, VOC_Term vt
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = vt._Term_key
			and vt.term = 'HomoloGene'
			and exists (select 1
				from MRK_ClusterMember ocm, MGI_Organism mo,
					MRK_Marker om
				where mc._Cluster_key = ocm._Cluster_key
				and ocm._Marker_key = om._Marker_key
				and om._Organism_key = mo._Organism_key
				and mo.commonName = 'dog, domestic')'''),

	('homologyCattle',
	'Mouse protein coding genes in homology classes with Cattle genes',
	'Mouse protein coding genes in homology classes with Cattle genes',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc, VOC_Term vt
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = vt._Term_key
			and vt.term = 'HomoloGene'
			and exists (select 1
				from MRK_ClusterMember ocm, MGI_Organism mo,
					MRK_Marker om
				where mc._Cluster_key = ocm._Cluster_key
				and ocm._Marker_key = om._Marker_key
				and om._Organism_key = mo._Organism_key
				and mo.commonName = 'cattle')'''),

	('homologyChicken',
	'Mouse protein coding genes in homology classes with Chicken genes',
	'Mouse protein coding genes in homology classes with Chicken genes',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc, VOC_Term vt
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = vt._Term_key
			and vt.term = 'HomoloGene'
			and exists (select 1
				from MRK_ClusterMember ocm, MGI_Organism mo,
					MRK_Marker om
				where mc._Cluster_key = ocm._Cluster_key
				and ocm._Marker_key = om._Marker_key
				and om._Organism_key = mo._Organism_key
				and mo.commonName = 'chicken')'''),

	('homologyZebrafish',
	'Mouse protein coding genes in homology classes with Zebrafish genes',
	'Mouse protein coding genes in homology classes with Zebrafish genes',
	'''select count(distinct mcv._Marker_key)
		from MRK_MCV_Cache mcv, MRK_Marker m, MRK_ClusterMember mcm, 
			MRK_Cluster mc, VOC_Term vt
		where mcv.term = 'protein coding gene'
			and mcv.qualifier = 'D'
			and mcv._Marker_key = m._Marker_key
			and m._Marker_Status_key in (1,3)
			and m._Organism_key = 1
			and m._Marker_key = mcm._Marker_key
			and mcm._Cluster_key = mc._Cluster_key
			and mc._ClusterSource_key = vt._Term_key
			and vt.term = 'HomoloGene'
			and exists (select 1
				from MRK_ClusterMember ocm, MGI_Organism mo,
					MRK_Marker om
				where mc._Cluster_key = ocm._Cluster_key
				and ocm._Marker_key = om._Marker_key
				and om._Organism_key = mo._Organism_key
				and mo.commonName = 'zebrafish')'''),

	]

# create the statistic records in the database

allStatistics = []

for (abbrev, name, definition, sql) in newStats:

	# 0 = not private; 1 = has integer value
	stat = stats.createStatistic (abbrev, name, definition, 0, 1)
	stat.setSql(sql)
	allStatistics.append(stat)

report ('Created Statistic records')

# get the two groups with orthology statistics, so we can repurpose them

orthoMiniHomeGroup = stats.StatisticGroup('Orthology Mini Home')
orthoStatsPageGroup = stats.StatisticGroup('Stats Page Orthology')

# assign the new statistic records to be members of the groups.  This will
# also drop the old group members.

orthoMiniHomeGroup.setStatistics(allStatistics)
orthoStatsPageGroup.setStatistics(allStatistics)

report ('Assigned Statistics to groups')

# now compute new measurements to ensure that the new statistics have one.
# SKIP THIS AS THE MIGRATION ALREADY DOES THIS IN PART 3.
#stats.measureAllHavingSql()
#report ('Computed new measurements')

db.useOneConnection(0)

report ('Finished')
