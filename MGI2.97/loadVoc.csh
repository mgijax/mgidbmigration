#!/bin/csh -f

#
# Load VOC vocabularies
#

cd `dirname $0` && source ./Configuration

which Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
${VOCLOAD}/runSimpleFullLoadNoArchive.sh `pwd`/indexpriority.config
${VOCLOAD}/runSimpleFullLoadNoArchive.sh `pwd`/indexassay.config
${VOCLOAD}/runSimpleFullLoadNoArchive.sh `pwd`/indexstages.config

date >> $LOG
