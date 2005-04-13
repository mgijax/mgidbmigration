#!/bin/csh -f

#
# Load VOC vocabularies
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date > ${LOG}
echo "Vocabulary Migration..." | tee -a ${LOG}
 
${VOCSIMPLELOAD} `pwd`/evidence.config >>& ${LOG}

date >> ${LOG}
