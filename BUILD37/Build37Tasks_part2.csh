#!/bin/csh -f

#
# Build 37 Tasks - Part 2
#
# This script is run after installing the Java Libraries and loads.
# 
#
# This script accomplishes the following tasks:
#  1) Broadcasts novel genes
#  2) Run gene model association loads
#  3) Run EG load
#  4) Run SWISS-Prot load
#  5) Run coordinate loads

cd `dirname $0` && source ../Configuration

date
echo "$0"

#
# Broadcast the build 37 novel genes.  The broadcast script also runs the
# mapping load using the input file that was created by the initial nomen load.
#
date
echo 'Nomen Broadcast'
${NOMENLOAD}/broadcast.csh ${NOMENLOAD}/ensembl.config
${NOMENLOAD}/broadcast.csh ${NOMENLOAD}/ncbi.config
${NOMENLOAD}/broadcast.csh ${NOMENLOAD}/vega.config

#
# Run all gene model associations loads.
#
date
echo 'ENSEMBL Gene Model/Association load'
${ASSEMBLYSEQLOAD}/bin/assemblyseqload.sh ensembl_assemblyseqload.config
date
echo 'NCBI Gene Model/Association load'
${ASSEMBLYSEQLOAD}/bin/assemblyseqload.sh ncbi_assemblyseqload.config
date
echo 'VEGA Gene Model/Association load'
${ASSEMBLYSEQLOAD}/bin/assemblyseqload.sh vega_assemblyseqload.config

#
# Run egload then swissload (egload deletes swissload created associations).
#
date
echo 'EG load (to make additional NCBI Gene Model/Marker associations)'
${EGLOAD}/bin/egload.sh

date
echo 'SWISS-PROT Load'
${SWISSLOAD}/preswissload.csh
${SWISSLOAD}/swissload.csh

#
# Run the marker coordinate loads.
#
date
echo 'miRBASE Association/Coordinate/Mapping load'
${MIRBASELOAD}/mirbaseload.sh

date
echo 'QTL Coordinate/Nomen load'
${COORDLOAD}/bin/qtlcoordload.sh qtl_coordload.config

date
echo 'Roopenian STS Load'
${COORDLOAD}/bin/coordload.sh roopenian_sts_coordload.config

date
echo 'UniSTS load'
${UNISTSLOAD}/unistsload.sh

date
echo 'Marker Location Cache Load'
${MRKCACHELOAD}/mrklocation.csh

date
echo 'Create MGI_GTGUP.gff Report'
cd ${PUBRPTS}
source ./Configuration
cd daily
MGI_GTGUP.py
cp ${REPORTOUTPUTDIR}/MGI_GTGUP.gff ${FTPREPORTDIR}

echo 'Completed'
date
