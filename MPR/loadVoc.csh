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
 
${VOCLOAD} `pwd`/inheritance.config >>& ${LOG}
${VOCLOAD} `pwd`/mutation.config >>& ${LOG}
${VOCLOAD} `pwd`/status.config >>& ${LOG}
${VOCLOAD} `pwd`/type.config >>& ${LOG}

date >> ${LOG}
