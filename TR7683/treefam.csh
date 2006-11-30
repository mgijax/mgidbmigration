#!/bin/csh -f

#
# TR 7526 TreeFam load
#
# Usage:  treefam.csh
#

source ../Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

${TREEFAMLOAD}/treefam.sh | tee -a ${LOG}

date >> ${LOG}

