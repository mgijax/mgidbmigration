#!/bin/csh -f

#
# Migration for: Allele Pair
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'Allele Pair Migration...' | tee -a ${LOG}

./unmigratedAlleleState.py

date >> ${LOG}

