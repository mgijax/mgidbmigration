#!/bin/csh -x -f

#
# After new java libraries are built, then run this
#

source /usr/local/mgi/live/dbutils/mgidbutilities/Configuration

date
echo 'Mouse EntrezGene load'
${DATALOADDIR}/egload/bin/egload.sh

date
echo 'SWISS-PROT Load'
${DATALOADDIR}/swissload/preswissload.csh
${DATALOADDIR}/swissload/swissload.csh

date
echo 'Load Sequence Cache tables'
${MGIDBUTILSDIR}/seqcacheload/seqmarker.csh

date
echo 'Load Marker Cache tables'
${MGIDBUTILSDIR}/mrkcacheload/mrkref.csh
${MGIDBUTILSDIR}/mrkcacheload/mrklocation.csh
date

