#!/bin/csh -fx

#
# Migration for 3.44 (TR 7379)
#
# Defaults:       6
# Procedures:   122
# Rules:          5
# Triggers:     159
# User Tables:  192
# Views:        230
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
./mgisnp.csh | tee -a ${LOG}
./mgimgd.csh | tee -a ${LOG}
./mgiradar.csh | tee -a ${LOG}

date | tee -a  ${LOG}

