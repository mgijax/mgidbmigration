#!/bin/csh -f

#
# Load VOC vocabularies
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo "Vocabulary Migration..." | tee -a ${LOG}
 
${VOCLOAD} `pwd`/qualifier.config >>& ${LOG}
${VOCLOAD} `pwd`/maptype.config >>& ${LOG}
${VOCLOAD} `pwd`/mapunits.config >>& ${LOG}

#./mlpstrain.py >>& ${LOG}
#${VOCLOAD} `pwd`/species.config >>& ${LOG}
#${VOCLOAD} `pwd`/straintype.config >>& ${LOG}

date >> ${LOG}
