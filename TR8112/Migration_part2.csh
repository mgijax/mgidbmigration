#!/bin/csh -fx

#
# Migration for TR8112 - MGI3.53
#
# This part of the migration is run AFTER the Java libraries and loads
# are installed.
#
# Defaults:       6
# Procedures:   111
# Rules:          5
# Triggers:     158
# User Tables:  187
# Views:        215
#

cd `dirname $0` && source ../Configuration

setenv LOG `pwd`/$0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}

# We are just running this as a test, the pipeline is not running
# therefore not using this file
echo "Running ${GBGTASSOCIATOR} | tee -a  ${LOG}
${GBGTASSOCIATOR}/bin/gbgtassociator.sh

echo "Creating gene trap cell line id to marker associations" | tee -a  ${LOG}
${ASSOCLOAD}/bin/AssocLoadDP.sh ${ASSOCLOAD}/DP.config.genetrap

echo "Creating hcop orthology load input" | tee -a  ${LOG}
${MGD_DBUTILS}/bin/generateHCOP.csh

echo "running hcp orthology load" | tee -a  ${LOG}
${ORTHOLOGYLOAD}/bin/orthologyload.csh ${ORTHOLOGYLOAD}/hcop.config

echo "running mrkref cacheload" | tee -a  ${LOG}
${MRKCACHELOAD}/mrkref.csh

echo "running mrklabel cacheload" | tee -a  ${LOG}
${MRKCACHELOAD}/mrklabel.csh

date | tee -a  ${LOG}
