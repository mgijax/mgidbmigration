#!/bin/csh -f

#
# Load VOC vocabularies
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
echo "Vocabulary Migration..." | tee -a $LOG
 
cellLine.py

${VOCLOAD} `pwd`/gender.config >>& $LOG
${VOCLOAD} `pwd`/genefamily.config >>& $LOG
${VOCLOAD} `pwd`/cellLine.config >>& $LOG
${VOCLOAD} `pwd`/curationstate.config >>& $LOG
${VOCLOAD} `pwd`/nomenstatus.config >>& $LOG
${VOCLOAD} `pwd`/sequencequal.config >>& $LOG
${VOCLOAD} `pwd`/sequencestatus.config >>& $LOG
${VOCLOAD} `pwd`/sequencetype.config >>& $LOG
${VOCLOAD} `pwd`/userstatus.config >>& $LOG
${VOCLOAD} `pwd`/usertype.config >>& $LOG
${VOCLOAD} `pwd`/vectortype.config >>& $LOG
${VOCLOAD} `pwd`/provider.config >>& $LOG

date >> $LOG
