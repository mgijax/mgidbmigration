#!/usr/local/bin/python

# patches four statistics for changes just prior to 4.0 release

import stats
import sys
import db

###-------------------------------###
###--- command-line processing ---###
###-------------------------------###

try:
	DB_USER = sys.argv[1]		# database username
	PWD_FILE = sys.argv[2]		# password file
	DB_SRV = sys.argv[3]		# database server name
	MGD_DB = sys.argv[4]		# mgd database name
	SNP_DB = sys.argv[5]		# snp database name
except:
	sys.stderr.write ('Usage: %s <db username> <db password file> <db server> <mgd db name> <snp db name>\n' % sys.argv[0])
	sys.exit(1)

try:
	fp = open(PWD_FILE, 'r')
	PWD = fp.readline().strip()
	fp.close()
except:
	sys.stderr.write ('read of %s failed\n' % PWD_FILE)
	sys.exit(1)

try:
	db.set_sqlLogin (DB_USER, PWD, DB_SRV, MGD_DB)
	db.sql ('SELECT COUNT(1) FROM MGI_dbInfo', 'auto')
except:
	sys.stderr.write ('mgd database login failed\n')
	sys.exit(1)

try:
	db.sql ('SELECT COUNT(1) FROM %s..MGI_dbInfo' % SNP_DB, 'auto')
except:
	sys.stderr.write ('snp database login failed\n')
	sys.exit(1)

###------------------------------------------------------------------------###

stats.setSqlFunction (db.sql)

###-------------------###
###--- defect 1848 ---###
###-------------------###

polyGenes = stats.getStatistic ('polyGenes')
polyGenes.setName ('Genes with polymorphisms (RFLP, PCR)')
sys.stderr.write ('updated polyGenes name\n')

polyMarkers = stats.getStatistic ('polyMarkers')
polyMarkers.setName ('Markers with polymorphisms (RFLP, PCR)')
sys.stderr.write ('updated polyMarkers name\n')
polyMarkers.setSql ('''SELECT COUNT(DISTINCT pr._Marker_key)
	FROM PRB_RFLV pr, MRK_Marker m
	WHERE pr._Marker_key = m._Marker_key
		AND m._Marker_Status_key IN (1,3)''')
sys.stderr.write ('updated polyMarkers SQL\n')

pmCount = db.sql (polyMarkers.getSql(), 'auto')[0]['']
stats.recordMeasurement ('polyMarkers', pmCount, None)
sys.stderr.write ('added new polyMarkers measurement\n')

# defer request for new SNP stats until we can define desired distance from
# each gene or marker

###-------------------###
###--- defect 1884 ---###
###-------------------###

gxdGenesRes = stats.getStatistic ('gxdGenesRes')
gxdGenesRes.setName ('Genes with expression assay results')
sys.stderr.write ('updated gxdGenesRes name\n')

###-------------------###
###--- defect 1885 ---###
###-------------------###

ortho = stats.getStatistic ('ortho')
gxdGenesRes.setName ('Genes with orthologs')
sys.stderr.write ('updated ortho name\n')

###-------------------###
###--- defect 1886 ---###
###-------------------###

gxdImages = stats.getStatistic ('gxdImages')
gxdImages.setSql ('''SELECT COUNT(DISTINCT p._ImagePane_key)
	FROM IMG_Image i, IMG_ImagePane p
	WHERE i._Image_key = p._Image_key
		AND i._MGIType_key = 8
		AND i.xDim != null
		AND i.yDim != null
		AND (p._ImagePane_key IN (SELECT _ImagePane_key
				FROM GXD_Assay)
			OR p._ImagePane_key IN (SELECT _ImagePane_key
				FROM GXD_InSituResultImage))''') 
sys.stderr.write ('updated gxdImages SQL\n')

imgCount = db.sql (gxdImages.getSql(), 'auto')[0]['']
stats.recordMeasurement ('gxdImages', imgCount, None)
sys.stderr.write ('added new gxdImages measurement\n')

sys.stderr.write ('done.')
