#!/usr/local/bin/python

import sys
import db
import stats

USAGE = "USAGE: %s <server> <database> <username> <password file>" % \
	sys.argv[0]

if len(sys.argv) != 5:
	print USAGE
	sys.exit(1)

try:
	fp = open(sys.argv[4], 'r')
	password = fp.readline().strip()
	fp.close()
except:
	print USAGE
	print 'Error: cannot open password file'
	sys.exit(1)

try:
	db.set_sqlLogin (sys.argv[3], password, sys.argv[1], sys.argv[2])
	db.sql ('select count(1) from MGI_dbInfo', 'auto')
except:
	print USAGE
	print 'Error: database login failed'
	sys.exit(1)

stats.setSqlFunction (db.sql)

gxdGenesRes = stats.getStatistic('gxdGenesRes')
gxdGenesRes.setSql (gxdGenesRes.getSql() + ' and ge.isForGXD = 1')

gxdResults = stats.getStatistic('gxdResults')
gxdResults.setSql (gxdResults.getSql() + ' where ge.isForGXD = 1')

gxdMutants = stats.getStatistic('gxdMutants')
gxdMutants.setSql (gxdMutants.getSql() + ' and e.isForGXD = 1')

gxdAssays = stats.getStatistic('gxdAssays')
gxdAssays.setSql ('''select count(distinct _Assay_key)
	from GXD_Expression
	where isForGXD = 1''')

gxdImages = stats.getStatistic('gxdImages')
gxdImages.setSql ('''SELECT COUNT(DISTINCT p._ImagePane_key)
	FROM IMG_Image i, IMG_ImagePane p
	WHERE i._Image_key = p._Image_key
		AND i._MGIType_key = 8
		AND i.xDim != null
		AND i.yDim != null
		AND (p._ImagePane_key IN (SELECT ga._ImagePane_key
				FROM GXD_Assay ga, GXD_Expression ge
                                WHERE ga._Assay_key = ge._Assay_key
                                and ge.isForGXD = 1)
			OR p._ImagePane_key IN (SELECT isr._ImagePane_key
				FROM GXD_InSituResultImage isr,
					GXD_InSituResult gis,
					GXD_Specimen gs,
					GXD_Expression ge
				WHERE isr._Result_key = gis._Result_key
					and gis._Specimen_key = gs._Specimen_key
					and gs._Assay_key = ge._Assay_key
					and ge.isForGXD = 1))''')
