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
 
${VOCSIMPLELOAD} `pwd`/inheritance.config >>& ${LOG}
${VOCSIMPLELOAD} `pwd`/mutation.config >>& ${LOG}
${VOCSIMPLELOAD} `pwd`/status.config >>& ${LOG}
${VOCSIMPLELOAD} `pwd`/type.config >>& ${LOG}
${VOCSIMPLELOAD} `pwd`/allelestate.config >>& ${LOG}
${VOCSIMPLELOAD} `pwd`/categories.config >>& ${LOG}
${VOCSIMPLELOAD} `pwd`/categories2.config >>& ${LOG}
${VOCSIMPLELOAD} `pwd`/compound.config >>& ${LOG}

date >> ${LOG}
