#!/bin/csh -fx

#
# TR11248
#
#  sto135
#
#

cd `dirname $0` && source ../Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
./sto135.py | tee -a ${LOG}
date | tee -a  ${LOG}

