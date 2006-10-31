#!/bin/csh -fx

#
# Migration for TR533
#

source ../Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
./go.csh | tee -a ${LOG}
date | tee -a  ${LOG}

