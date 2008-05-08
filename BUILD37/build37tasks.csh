#!/bin/csh -f

#
# Build 37 Tasks
#
# This script depends on the following having been done:
#  1) run dbsnpload on lindon
#  2) run gtlitepipeline on hobbiton
#  3) mgd Nomen tables have been loaded with new Build37 genes 

cd `dirname $0` && source ./Configuration

date
echo "$0"

#
# Load databases (development builds only).
#
#date
#${MGI_DBUTILS}/bin/load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup
#${MGI_DBUTILS}/bin/load_db.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} /shire/sybase/radar.backup

#
# Backup databases before proceeding (production only).
#
#date
#echo 'Backup mgd/radar databases'
#${MGI_DBUTILS}/bin/dump_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /extra1/sybase/mgd.preBuild37.backup
#${MGI_DBUTILS}/bin/dump_db.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} /extra1/sybase/radar.preBuild37.backup

#
# Run the migration to remove obsolete gene models and curator associations.
#
#date
#${DBUTILS}/mgidbmigration/BUILD37/MGI.csh

#
# Broadcast the build 37 novel genes.  The broadcast script also runs the
# mapping load using the input file that was created by the initial nomen load.
#
#date
#echo 'Nomen Broadcast'
#${NOMENLOAD}/broadcast.csh ${NOMENLOAD}/ensembl.config
#${NOMENLOAD}/broadcast.csh ${NOMENLOAD}/ncbi.config
#${NOMENLOAD}/broadcast.csh ${NOMENLOAD}/vega.config

#
# Run all gene model associations loads.
#
#date
#echo 'ENSEMBL Gene Model/Association load'
#${ASSEMBLYSEQLOAD}/bin/assemblyseqload.sh ensembl_assemblyseqload.config
#date
#echo 'NCBI Gene Model/Association load'
#${ASSEMBLYSEQLOAD}/bin/assemblyseqload.sh ncbi_assemblyseqload.config
#date
#echo 'VEGA Gene Model/Association load'
#${ASSEMBLYSEQLOAD}/bin/assemblyseqload.sh vega_assemblyseqload.config

#
# Run egload then swissload (egload deletes swissload created associations).
#
#date
#echo 'EG load (to make additional NCBI Gene Model/Marker associations)'
#${EGLOAD}/bin/egload.sh

#date
#echo 'SWISS-PROT Load'
#${SWISSLOAD}/preswissload.csh
#${SWISSLOAD}/swissload.csh

#
# Run the marker coordinate loads.
#
#date
#echo 'miRBASE Association/Coordinate/Mapping load'
#${MIRBASELOAD}/mirbaseload.sh

#date
#echo 'QTL Coordinate/Nomen load'
#${COORDLOAD}/bin/qtlcoordload.sh qtl_coordload.config

#date
#echo 'Roopenian STS Load'
#${COORDLOAD}/bin/coordload.sh roopenian_sts_coordload.config

#date
#echo 'UniSTS load'
#${UNISTSLOAD}/unistsload.sh

#
# Load gene trap lite associations (delete/reload mode).  Depends on
# gtlitepipeline having been run on hobbiton.
#
#echo 'Creating gene trap cell line id to marker associations'
#${ASSOCLOAD}/bin/AssocLoadDP.sh ${ASSOCLOAD}/DP.config.genetrap

#
# Load all cache tables.
#
#date
#echo 'Load Sequence Cache tables'
#${SEQCACHELOAD}/seqcoord.csh
#${SEQCACHELOAD}/seqmarker.csh
#${SEQCACHELOAD}/seqdescription.csh

#date
#echo 'Load Marker Cache tables'
#${MRKCACHELOAD}/mrklabel.csh
#${MRKCACHELOAD}/mrkref.csh
#${MRKCACHELOAD}/mrklocation.csh

# NOTE dbsnpload, via snpcacheload, runs snpmarker.csh now.

#
# Run QC and public reports.
#
# NOTE: mgd/SEQ_RepTransGenomic.py is needed for building GBrowse.
#date
#echo 'QC Reports'
#${QCRPTS}/qcnightly_reports.sh
#${QCRPTS}/qcweekly_reports.sh
#${QCRPTS}/qcmonthly_reports.sh

#date
#echo 'Public Reports'
#${PUBRPTS}/nightly_reports.sh
#${PUBRPTS}/weekly_reports.sh
#${PUBRPTS}/monthly_reports.sh

#
# Run GBrowse utilities.
#
#date
#echo 'GBrowse Utilities'
#${GBROWSEUTILS}/bin/generateReports.sh

#
# Backup databases.
#
#date
#echo 'Backup mgd/radar databases'
#${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME} ${RADAR_DBNAME}" Build37

echo 'Completed'
date

