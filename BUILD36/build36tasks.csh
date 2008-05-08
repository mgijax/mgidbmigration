#!/bin/csh -x -f

#
# Build 36 Tasks
#

cd `dirname $0` && source ./Configuration

date
echo '$0'

#date
#${DBUTILS}/mgidbutilities/bin/load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup
#${DBUTILS}/mgidbutilities/bin/load_db.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} /shire/sybase/radar.backup
#${DBUTILS}/mgidbmigration/BUILD36/MGI.csh

#date
#echo 'Nomen Broadcast'
#${DATALOAD}/nomenload/broadcast.csh ensembl.config
#${DATALOAD}/nomenload/broadcast.csh ncbi.config
#${DATALOAD}/nomenload/broadcast.csh vega.config

date
echo 'NCBI Coordinate load'
${DATALOAD}/assemblyseqload/bin/assemblyseqload.sh ncbi_assemblyseqload.config

#date
#echo 'ENSEMBL Coordinate load'
#${DATALOAD}/assemblyseqload/bin/assemblyseqload.sh ensembl_assemblyseqload.config

#date
#echo 'VEGA Coordinate load'
#${DATALOAD}/assemblyseqload/bin/assemblyseqload.sh vega_assemblyseqload.config

date
echo 'EG load (to make NCBI Gene Model/Marker associations)'
${DATALOAD}/egload/bin/egload.sh

date
echo 'SWISS-PROT Load'
${DATALOAD}/swissload/preswissload.csh
${DATALOAD}/swissload/swissload.csh

#date
#echo 'miRBASE Association/Coordinate/Mapping load'
#${DATALOAD}/mirbaseload/mirbaseload.sh

#date
#echo 'QTL Coordinate/Nomen load'
#${DATALOAD}/coordload/bin/qtlcoordload.sh qtl_coordload.config

#date
#echo 'UniSTS load'
#${DATALOAD}/unistsload/unistsload.sh

date
echo 'Load Sequence Cache tables'
${DBUTILS}/seqcacheload/seqcoord.csh
${DBUTILS}/seqcacheload/seqmarker.csh
${DBUTILS}/seqcacheload/seqdescription.csh

date
echo 'Load Marker Cache tables'
${DBUTILS}/mrkcacheload/mrkref.csh
${DBUTILS}/mrkcacheload/mrklocation.csh

#date
#echo 'Obsolete Gene Models with Deleted Sequences'
#${DATALOAD}/nomenload/nomenbatch.csh autoobsolete.config

#date
#echo 'Load SNP/Marker Cache table'
#${DBUTILS}/snpcacheload/snpmarker.csh

#date
#echo 'Backup'
#${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME}" mgdbuild36

echo 'Completed'
date

