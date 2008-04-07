#!/bin/csh -x -f

#
# Build 37 Tasks
#
# This script depends on the following having been done:
#  1) run dbsnpload on lindon
#  2) run gtlitepipeline on hobbiton
#  3) mgd Nomen tables have been loaded with new Build37 genes 

cd `dirname $0` && source ./Configuration

date
echo '$0'

#
# load databases for development builds only
#

#date
#${DBUTILS}/mgidbutilities/bin/load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup
#${DBUTILS}/mgidbutilities/bin/load_db.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} /shire/sybase/radar.backup

#
# run the migration to remove obsolete gene models and curator made associations
#

#${DBUTILS}/mgidbmigration/BUILD37/MGI.csh

#
# Broadcast the build 37 novel genes
#

#date
#echo 'Nomen Broadcast'
#${DATALOAD}/nomenload/broadcast.csh ensembl.config
#${DATALOAD}/nomenload/broadcast.csh ncbi.config
#${DATALOAD}/nomenload/broadcast.csh vega.config

#
# Run mapping loads for each set of broadcast genes; input having been 
# created when initial nomenload
#

#date
#echo "Mapping Loads'

#
# Run all gene model associations loads
#

#date
#echo 'NCBI Gene Model/Association load'
#${DATALOAD}/assemblyseqload/bin/assemblyseqload.sh ncbi_assemblyseqload.config

#date
#echo 'ENSEMBL Gene Model/Association load'
#${DATALOAD}/assemblyseqload/bin/assemblyseqload.sh ensembl_assemblyseqload.config

#date
#echo 'VEGA Gene Model/Association load'
#${DATALOAD}/assemblyseqload/bin/assemblyseqload.sh vega_assemblyseqload.config


#
# run egload then swissload (egload deletes swissload created associations)
#
#date
#echo 'EG load (to make additional NCBI Gene Model/Marker associations)'
#${DATALOAD}/egload/bin/egload.sh

#date
#echo 'SWISS-PROT Load'
#${DATALOAD}/swissload/preswissload.csh
#${DATALOAD}/swissload/swissload.csh

#
# Run the marker coordinate loads
#

#$date
#$echo 'miRBASE Association/Coordinate/Mapping load'
#$${DATALOAD}/mirbaseload/mirbaseload.sh

#date
#echo 'QTL Coordinate/Nomen load'
#${DATALOAD}/coordload/bin/qtlcoordload.sh qtl_coordload.config

#date
#echo 'Roopenian STS Load'
# ...

#date
#echo 'UniSTS load'
#${DATALOAD}/unistsload/unistsload.sh

#
# Load gene trap lite associations - delete/reload mode
# depends on gtlitepipeline having been run on hobbiton
#

#echo "Creating gene trap cell line id to marker associations" | tee -a  ${LOG}
#${ASSOCLOAD}/bin/AssocLoadDP.sh ${ASSOCLOAD}/DP.config.genetrap

#
# load all cache tables
#

#date
#echo 'Load Sequence Cache tables'
#${DBUTILS}/seqcacheload/seqcoord.csh
#${DBUTILS}/seqcacheload/seqmarker.csh
#${DBUTILS}/seqcacheload/seqdescription.csh

#$date
#$echo 'Load Marker Cache tables'
#$${DBUTILS}/mrkcacheload/mrkref.csh
#$${DBUTILS}/mrkcacheload/mrklocation.csh

# note dbsnpload, via snpcacheload, runs snpmarker.csh now

#
# run qc and public reports, some needed to generate gbrowse files
#

#date
#echo 'Public Reports'

#date
# note: mgd/SEQ_RepTransGenomic.py is needed for building gbrowse
#echo 'QC Reports'

#
# run gbrowse utilities
#

#date
#echo 'GBrowse Utilities'
#${GBROWSEUTILS}/bin/generateReports.sh

#date
#echo 'Backup'
#${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME}" mgdbuild37

echo 'Completed'
date

